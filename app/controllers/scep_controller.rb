class ScepController < ApplicationController

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

  def index

    case params[:operation]
    when 'PKIOperation'
    
      raw_message = request.raw_post

      temp = Tempfile.new SecureRandom.hex
      temp.binmode
      temp.write raw_message
      temp.close

      asn1parse = `openssl asn1parse -in #{temp.path} -inform DER`
      
      message_type_id = asn1parse.match(/OBJECT\s+:#{MessageType}\n.+\n.+PRINTABLESTRING\s+:(.+)/)[1].to_i
      transaction_id  = asn1parse.match(/OBJECT\s+:#{TransId    }\n.+\n.+PRINTABLESTRING\s+:(.+)/)[1]
      sender_nonce    = asn1parse.match(/OBJECT\s+:#{SenderNonce}\n.+\n.+OCTET STRING\s+\[HEX DUMP\]:(.+)/)[1]

      temp.unlink

      case message_type_id
      when MessageTypes['PKCSReq']

        message = OpenSSL::PKCS7.new raw_message
        message.verify nil, SCEPStore, nil, OpenSSL::PKCS7::NOVERIFY

        sender_serial       = message.certificates.first.serial
        sender_common_name  = message.certificates.first.subject.to_a.select{|(k,v)| k == 'CN'}.first[1]
        recipient_key       = message.certificates.first.public_key
        
        message_envelope = OpenSSL::PKCS7.new(message.data)
        x509_request = OpenSSL::X509::Request.new message_envelope.decrypt(SCEPKey, SCEPCert, nil)
        
        challenge_password = x509_request.attributes.select{|a| a.oid == 'challengePassword' }.first
        challenge_password = challenge_password && challenge_password.value.value.first.value
        device_id, challenge_password = challenge_password.split(':')

        device = Device.find(device_id)

        if device && (device.secret == challenge_password) && x509_request.verify(x509_request.public_key)

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

          degenerate = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.2'),
            OpenSSL::ASN1::ASN1Data.new([
              OpenSSL::ASN1::Sequence.new([
                OpenSSL::ASN1::Integer.new(1),
                OpenSSL::ASN1::Set.new([
                ]),
                OpenSSL::ASN1::Sequence.new([
                  OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1')
                ]),
                OpenSSL::ASN1::ASN1Data.new([
                  OpenSSL::ASN1.decode(new_cert.to_der)
                ], 0, :CONTEXT_SPECIFIC),
                OpenSSL::ASN1::ASN1Data.new([
                ], 1, :CONTEXT_SPECIFIC),
                OpenSSL::ASN1::Set.new([
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

          recipient_information = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1.decode(message.certificates.first.subject.to_der),
            OpenSSL::ASN1::Integer.new(sender_serial.to_i)
          ])

          envelope = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.3'),
            OpenSSL::ASN1::ASN1Data.new([
              OpenSSL::ASN1::Sequence.new([
                OpenSSL::ASN1::Integer.new(0),
                OpenSSL::ASN1::Set.new([
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::Integer.new(0),
                    recipient_information,
                    OpenSSL::ASN1::Sequence.new([
                      OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.1.1'),
                      OpenSSL::ASN1::Null.new(nil)
                    ]),
                    OpenSSL::ASN1::OctetString.new( recipient_key.public_encrypt content_encryption_key )
                  ])
                ]),
                OpenSSL::ASN1::Sequence.new([
                  OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1'),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.2.840.113549.3.7'),
                    OpenSSL::ASN1::OctetString.new( content_encryption_iv )
                  ]),
                  OpenSSL::ASN1::ASN1Data.new( encrypted_payload, 0, :CONTEXT_SPECIFIC)
                ])
              ])
            ], 0, :CONTEXT_SPECIFIC)
          ])

          text = envelope.to_der
          message_digest = sha1.digest text
          now = Time.now

          signed_attributes = OpenSSL::ASN1::ASN1Data.new([
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.3'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1')
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.5'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::UTCTime.new(now)
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.4'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( message_digest )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( MessageType ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( MessageTypes['CertRep'].to_s )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( PkiStatus ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( PkiStatuses['SUCCESS'].to_s )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new(RecipientNonce),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( [sender_nonce].pack('H*') )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new(SenderNonce),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( [SecureRandom.hex].pack('H*') )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( TransId ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( transaction_id )
              ])
            ])
          ], 0, :CONTEXT_SPECIFIC)

          signed_attributes_digest = SCEPKey.private_encrypt OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'),
              OpenSSL::ASN1::Null.new(nil)
            ]),
            OpenSSL::ASN1::OctetString.new( sha1.digest OpenSSL::ASN1::Set.new(signed_attributes.value[0..-1]).to_der )
          ]).to_der

          pki_message = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.2'),
            OpenSSL::ASN1::ASN1Data.new([OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::Integer.new(1), 
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::Sequence.new([ 
                  OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'), 
                  OpenSSL::ASN1::Null.new(nil)
                ])
              ]),
              OpenSSL::ASN1::Sequence.new([
                OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1'),
                OpenSSL::ASN1::ASN1Data.new([
                  OpenSSL::ASN1::OctetString.new( text )
                ], 0, :CONTEXT_SPECIFIC)
              ]),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::Sequence.new([
                  OpenSSL::ASN1::Integer.new(1),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1.decode(SCEPCert.subject.to_der),
                    OpenSSL::ASN1::Integer.new( SCEPCert.serial )
                  ]),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'),
                    OpenSSL::ASN1::Null.new(nil)
                  ]),
                  signed_attributes,
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.1.1'),
                    OpenSSL::ASN1::Null.new(nil)
                  ]),
                  OpenSSL::ASN1::OctetString.new( signed_attributes_digest )
                ]),
              ])
            ])
            ], 0, :CONTEXT_SPECIFIC)
          ])

          send_data pki_message.to_der, :content_type => 'application/x-pki-message'

        else

          sha1 = OpenSSL::Digest::SHA1.new

          des = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
          des.encrypt
          content_encryption_key = des.random_key
          content_encryption_iv  = des.random_iv
          des.key = content_encryption_key
          des.iv  = content_encryption_iv

          degenerate = OpenSSL::ASN1::Sequence.new([
          ])

          encrypted_payload = des.update(degenerate.to_der) + des.final

          recipient_information = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1.decode(message.certificates.first.subject.to_der),
            OpenSSL::ASN1::Integer.new(sender_serial.to_i)
          ])

          envelope = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.3'),
            OpenSSL::ASN1::ASN1Data.new([
              OpenSSL::ASN1::Sequence.new([
                OpenSSL::ASN1::Integer.new(0),
                OpenSSL::ASN1::Set.new([
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::Integer.new(0),
                    recipient_information,
                    OpenSSL::ASN1::Sequence.new([
                      OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.1.1'),
                      OpenSSL::ASN1::Null.new(nil)
                    ]),
                    OpenSSL::ASN1::OctetString.new( recipient_key.public_encrypt content_encryption_key )
                  ])
                ]),
                OpenSSL::ASN1::Sequence.new([
                  OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1'),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.2.840.113549.3.7'),
                    OpenSSL::ASN1::OctetString.new( content_encryption_iv )
                  ]),
                  OpenSSL::ASN1::ASN1Data.new( encrypted_payload, 0, :CONTEXT_SPECIFIC)
                ])
              ])
            ], 0, :CONTEXT_SPECIFIC)
          ])

          text = envelope.to_der
          message_digest = sha1.digest text
          now = Time.now

          signed_attributes = OpenSSL::ASN1::ASN1Data.new([
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.3'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1')
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.5'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::UTCTime.new(now)
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.9.4'),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( message_digest )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( MessageType ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( MessageTypes['CertRep'].to_s )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( PkiStatus ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( PkiStatuses['FAILURE'].to_s )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( FailInfo ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( FailInfos['badRequest'].to_s )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new(RecipientNonce),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( [sender_nonce].pack('H*') )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new(SenderNonce),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::OctetString.new( [SecureRandom.hex].pack('H*') )
              ])
            ]),
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new( TransId ),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::PrintableString.new( transaction_id )
              ])
            ])
          ], 0, :CONTEXT_SPECIFIC)

          signed_attributes_digest = SCEPKey.private_encrypt OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'),
              OpenSSL::ASN1::Null.new(nil)
            ]),
            OpenSSL::ASN1::OctetString.new( sha1.digest OpenSSL::ASN1::Set.new(signed_attributes.value[0..-1]).to_der )
          ]).to_der

          pki_message = OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.2'),
            OpenSSL::ASN1::ASN1Data.new([OpenSSL::ASN1::Sequence.new([
              OpenSSL::ASN1::Integer.new(1), 
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::Sequence.new([ 
                  OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'), 
                  OpenSSL::ASN1::Null.new(nil)
                ])
              ]),
              OpenSSL::ASN1::Sequence.new([
                OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.7.1'),
                OpenSSL::ASN1::ASN1Data.new([
                  OpenSSL::ASN1::OctetString.new( text )
                ], 0, :CONTEXT_SPECIFIC)
              ]),
              OpenSSL::ASN1::Set.new([
                OpenSSL::ASN1::Sequence.new([
                  OpenSSL::ASN1::Integer.new(1),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1.decode(SCEPCert.subject.to_der),
                    OpenSSL::ASN1::Integer.new( SCEPCert.serial )
                  ]),
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.3.14.3.2.26'),
                    OpenSSL::ASN1::Null.new(nil)
                  ]),
                  signed_attributes,
                  OpenSSL::ASN1::Sequence.new([
                    OpenSSL::ASN1::ObjectId.new('1.2.840.113549.1.1.1'),
                    OpenSSL::ASN1::Null.new(nil)
                  ]),
                  OpenSSL::ASN1::OctetString.new( signed_attributes_digest )
                ]),
              ])
            ])
            ], 0, :CONTEXT_SPECIFIC)
          ])

          send_data pki_message.to_der, :content_type => 'application/x-pki-message'

        end

      else
        render :nothing => true, :status => :ok
      end
    when 'GetCACert'
      send_data SCEPCert.to_der, :content_type => 'application/x-x509-ca-cert'
    when 'GetCACaps'
      send_data "POSTPKIOperation\nSHA-1", :status => :ok, :content_type => 'text/plain'
    else
      render :nothing => true, :status => :ok
    end
  end

end
