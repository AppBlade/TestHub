class ScepController < ApplicationController

  include OpenSSL::ASN1

  MessageType    = "2.16.840.1.113733.1.9.2"
  PkiStatus      = "2.16.840.1.113733.1.9.3"
  FailInfo       = "2.16.840.1.113733.1.9.4"
  SenderNonce    = "2.16.840.1.113733.1.9.5"
  RecipientNonce = "2.16.840.1.113733.1.9.6"
  TransId        = "2.16.840.1.113733.1.9.7"
  ExtensionReq   = "2.16.840.1.113733.1.9.8"
  
  MessageTypes = {'PKCSReq' => 19, 'CertRep' => 3, 'GetCertInitial' => 20, 'GetCert' => 21, 'GetCRL' => 22}
  PkiStatuses = {'SUCCESS' => 0, 'FAILURE' => 2, 'PENDING' => 3}
  FailInfos = {'badAlg' => 0, 'badMessageCheck' => 1, 'badRequest' => 2, 'badTime' => 3, 'badCertId' => 4}

  skip_before_filter :verify_authenticity_token

  def get_ca_caps
    send_data "POSTPKIOperation\nSHA-1", :content_type => 'text/plain'
  end

  def get_ca_cert
    send_data SCEPCert.to_der, :content_type => 'application/x-x509-ca-cert'
  end

  def pki_operation

    raw_message = request.raw_post

    asn1 = decode raw_message
    raw_signed_attributes = asn1.value[1].value.first.value[4].first.value[3].value
    signed_attributes = raw_signed_attributes.inject({}) do |hash, raw_signed_attribute|
      hash.merge({raw_signed_attribute.value.first.value => raw_signed_attribute.value.last.value.first.value})
    end

    message_type_id = signed_attributes[MessageType]
    transaction_id  = signed_attributes[TransId]
    sender_nonce    = signed_attributes[SenderNonce].unpack('H*')[0]

    message = OpenSSL::PKCS7.new raw_message
    message.verify nil, SCEPStore, nil, OpenSSL::PKCS7::NOVERIFY

    sender_serial = message.certificates.first.serial
    recipient_key = message.certificates.first.public_key

    message_envelope = OpenSSL::PKCS7.new(message.data)
    x509_request = OpenSSL::X509::Request.new message_envelope.decrypt(SCEPKey, SCEPCert, nil)

    device_id, challenge_password = signed_attributes['challengePassword'].split(':')

    device = Device.find(device_id)

    raise ArgumentError, 'No matching device' unless device
    raise ArgumentError, 'Device secret doesnt match' unless device.secret == challenge_password
    raise ArgumentError, 'X509 verification failed' unless x509_request.verify(x509_request.public_key)

    new_serial = Random.rand(2**(159))

    new_cert = OpenSSL::X509::Certificate.new
    new_cert.serial = new_serial
    new_cert.version = 2
    new_cert.not_before = Time.now
    new_cert.not_after = 2.years.from_now
    new_cert.subject = x509_request.subject
    new_cert.public_key = x509_request.public_key
    new_cert.issuer = SCEPCert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = new_cert
    extension_factory.subject_request = x509_request
    extension_factory.issuer_certificate = SCEPCert

    new_cert.add_extension extension_factory.create_extension('keyUsage', 'digitalSignature,keyEncipherment')

    new_cert.sign SCEPKey, OpenSSL::Digest::SHA1.new

    device.secret_digest = nil
    device.certificate_serial = new_serial.to_s(16)
    device.save!

    degenerate = Sequence.new([
      ObjectId.new('1.2.840.113549.1.7.2'),
      ASN1Data.new([
        Sequence.new([
          Integer.new(1),
          Set.new([
          ]),
          Sequence.new([
            ObjectId.new('1.2.840.113549.1.7.1')
          ]),
          ASN1Data.new([
            decode(new_cert.to_der)
          ], 0, :CONTEXT_SPECIFIC),
          ASN1Data.new([
          ], 1, :CONTEXT_SPECIFIC),
          Set.new([
          ])
        ])
      ], 0, :CONTEXT_SPECIFIC)
    ])

    sha1 = OpenSSL::Digest::SHA1.new

    des = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
    des.encrypt
    content_encryption_key = des.random_key
    content_encryption_iv  = des.random_iv
    des.key = content_encryption_key
    des.iv  = content_encryption_iv

    encrypted_payload = des.update(degenerate.to_der) + des.final

    recipient_information = Sequence.new([
      decode(message.certificates.first.subject.to_der),
      Integer.new(sender_serial.to_i)
    ])

    envelope = Sequence.new([
      ObjectId.new('1.2.840.113549.1.7.3'),
      ASN1Data.new([
        Sequence.new([
          Integer.new(0),
          Set.new([
            Sequence.new([
              Integer.new(0),
              recipient_information,
              Sequence.new([
                ObjectId.new('1.2.840.113549.1.1.1'),
                Null.new(nil)
              ]),
              OctetString.new( recipient_key.public_encrypt content_encryption_key )
            ])
          ]),
          Sequence.new([
            ObjectId.new('1.2.840.113549.1.7.1'),
            Sequence.new([
              ObjectId.new('1.2.840.113549.3.7'),
              OctetString.new( content_encryption_iv )
            ]),
            ASN1Data.new( encrypted_payload, 0, :CONTEXT_SPECIFIC)
          ])
        ])
      ], 0, :CONTEXT_SPECIFIC)
    ])

    text = envelope.to_der
    message_digest = sha1.digest text
    now = Time.now

    signed_attributes = ASN1Data.new([
      Sequence.new([
        ObjectId.new('1.2.840.113549.1.9.3'),
        Set.new([
          ObjectId.new('1.2.840.113549.1.7.1')
        ])
      ]),
      Sequence.new([
        ObjectId.new('1.2.840.113549.1.9.5'),
        Set.new([
          UTCTime.new(now)
        ])
      ]),
      Sequence.new([
        ObjectId.new('1.2.840.113549.1.9.4'),
        Set.new([
          OctetString.new( message_digest )
        ])
      ]),
      Sequence.new([
        ObjectId.new( MessageType ),
        Set.new([
          PrintableString.new( MessageTypes['CertRep'].to_s )
        ])
      ]),
      Sequence.new([
        ObjectId.new( PkiStatus ),
        Set.new([
          PrintableString.new( PkiStatuses['SUCCESS'].to_s )
        ])
      ]),
      Sequence.new([
        ObjectId.new(RecipientNonce),
        Set.new([
          OctetString.new( [sender_nonce].pack('H*') )
        ])
      ]),
      Sequence.new([
        ObjectId.new(SenderNonce),
        Set.new([
          OctetString.new( [SecureRandom.hex].pack('H*') )
        ])
      ]),
      Sequence.new([
        ObjectId.new( TransId ),
        Set.new([
          PrintableString.new( transaction_id )
        ])
      ])
    ], 0, :CONTEXT_SPECIFIC)

    signed_attributes_digest = SCEPKey.private_encrypt Sequence.new([
      Sequence.new([
        ObjectId.new('1.3.14.3.2.26'),
        Null.new(nil)
      ]),
      OctetString.new( sha1.digest Set.new(signed_attributes.value[0..-1]).to_der )
    ]).to_der

    pki_message = Sequence.new([
      ObjectId.new('1.2.840.113549.1.7.2'),
      ASN1Data.new([Sequence.new([
        Integer.new(1), 
        Set.new([
          Sequence.new([ 
            ObjectId.new('1.3.14.3.2.26'), 
            Null.new(nil)
          ])
        ]),
        Sequence.new([
          ObjectId.new('1.2.840.113549.1.7.1'),
          ASN1Data.new([
            OctetString.new( text )
          ], 0, :CONTEXT_SPECIFIC)
        ]),
        Set.new([
          Sequence.new([
            Integer.new(1),
            Sequence.new([
              decode(SCEPCert.subject.to_der),
              Integer.new( SCEPCert.serial )
            ]),
            Sequence.new([
              ObjectId.new('1.3.14.3.2.26'),
              Null.new(nil)
            ]),
            signed_attributes,
            Sequence.new([
              ObjectId.new('1.2.840.113549.1.1.1'),
              Null.new(nil)
            ]),
            OctetString.new( signed_attributes_digest )
          ]),
        ])
      ])
      ], 0, :CONTEXT_SPECIFIC)
    ])

    send_data pki_message.to_der, :content_type => 'application/x-pki-message'

  end

end
