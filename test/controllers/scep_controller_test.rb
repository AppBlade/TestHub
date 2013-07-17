require 'test_helper'

class ScepControllerTest < ActionController::TestCase
  
  include OpenSSL::ASN1

  test 'CACaps' do
    get :get_ca_caps
    assert_response :success
    assert_equal @response.body.split, %w(POSTPKIOperation SHA-1)
  end

  test 'CACert' do
    get :get_ca_cert
    assert_response :success
    assert_equal @response.body, SCEPCert.to_der
  end
  
  test 'certificate generation' do
    
    device = devices(:james_macbook)

    key = OpenSSL::PKey::RSA.new 1024
    
    sha1 = OpenSSL::Digest::SHA1.new

    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = Random.rand(2**(159))
    cert.not_before = Time.now
    cert.not_after = Time.now + 10.minutes
    cert.public_key = key.public_key
    cert.subject = OpenSSL::X509::Name.parse "CN=MDM SCEP SIGNER/C=US"
    cert.issuer = OpenSSL::X509::Name.parse "CN=MDM SCEP SIGNER/C=US"
    cert.sign key, OpenSSL::Digest::SHA1.new

    csr_key = OpenSSL::PKey::RSA.new 1024
    csr = OpenSSL::X509::Request.new
    csr.public_key = csr_key.public_key
    csr.subject = OpenSSL::X509::Name.parse "CN=iPhone/C=US"
    csr.version = 0
    csr.attributes = [
      OpenSSL::X509::Attribute.new(
        'challengePassword',
        Set.new([
          PrintableString.new( "2:cf31b62eca246c154b26286c9dec95ce6150ac6e19c041b6e9d166910ad38fe4" )
        ])
      )
    ]
    csr.sign csr_key, sha1

    now = Time.now
    sender_nonce = SecureRandom.hex
    transaction_id = SecureRandom.hex
 
    des = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
    des.encrypt
    content_encryption_key = des.random_key
    content_encryption_iv  = des.random_iv
    des.key = content_encryption_key
    des.iv  = content_encryption_iv

    encrypted_payload = des.update(csr.to_der) + des.final

    recipient_information = Sequence.new([
      decode(SCEPCert.subject.to_der),
      Integer.new(SCEPCert.serial.to_i)
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
              OctetString.new( SCEPKey.public_encrypt content_encryption_key )
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
        ObjectId.new( 'challengePassword' ),
        Set.new([
          PrintableString.new( "2:cf31b62eca246c154b26286c9dec95ce6150ac6e19c041b6e9d166910ad38fe4" )
        ])
      ]),
      Sequence.new([
        ObjectId.new( ScepController::MessageType ),
        Set.new([
          PrintableString.new( ScepController::MessageTypes['PKCSReq'].to_s )
        ])
      ]),
      Sequence.new([
        ObjectId.new( ScepController::SenderNonce ),
        Set.new([
          OctetString.new( [sender_nonce].pack('H*') )
        ])
      ]),
      Sequence.new([
        ObjectId.new( ScepController::TransId ),
        Set.new([
          PrintableString.new( transaction_id )
        ])
      ])
    ], 0, :CONTEXT_SPECIFIC)

    signed_attributes_digest = key.private_encrypt Sequence.new([
      Sequence.new([
        ObjectId.new('1.3.14.3.2.26'),
        Null.new(nil)
      ]),
      OctetString.new( sha1.digest Set.new(signed_attributes.value[0..-1]).to_der )
    ]).to_der

    pki_message = Sequence.new([
      ObjectId.new('1.2.840.113549.1.7.2'),
      ASN1Data.new([
        Sequence.new([
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
          ASN1Data.new([
            decode(cert.to_der)
          ], 0, :CONTEXT_SPECIFIC),
          Set.new([
            Sequence.new([
              Integer.new(1),
              Sequence.new([ 
                decode(cert.subject.to_der),
                Integer.new( cert.serial )
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
            ])
          ])
        ])
      ], 0, :CONTEXT_SPECIFIC)
    ])

    post :pki_operation, pki_message.to_der.force_encoding('UTF-8'), content_type: 'application/x-pki-message'

    assert_response :success

    raw_message = @response.body
    message = OpenSSL::PKCS7.new raw_message

    asn1 = decode raw_message
    raw_signed_attributes = asn1.value[1].value.first.value[3].first.value[3].value
    signed_attributes = raw_signed_attributes.inject({}) do |hash, raw_signed_attribute|
      hash.merge({raw_signed_attribute.value.first.value => raw_signed_attribute.value.last.value.first.value})
    end

    assert_equal signed_attributes[ScepController::MessageType], '3'
    assert_equal signed_attributes[ScepController::TransId], transaction_id
    assert_equal signed_attributes[ScepController::PkiStatus], '0'
    assert_equal signed_attributes[ScepController::RecipientNonce].unpack('H*')[0], sender_nonce
    assert       signed_attributes[ScepController::SenderNonce].present?

    assert message.certificates.nil?
    assert_equal message.recipients, []
    assert_equal message.signers.size, 1
    assert_equal message.signers.first.name, SCEPCert.subject
    assert_equal message.signers.first.serial, SCEPCert.serial

    assert message.verify [SCEPCert], SCEPStore, nil, OpenSSL::PKCS7::NOVERIFY

    envelope = decode message.data

    content_encryption_key = key.private_decrypt envelope.value[1].value.first.value[1].value.first.value[3].value
    content_encryption_iv  = envelope.value[1].value.first.value[2].value[1].value[1].value
    
    des = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
    des.decrypt
    des.key = content_encryption_key
    des.iv  = content_encryption_iv
    
    degenerate = des.update(envelope.value[1].value.first.value[2].value[2].value) + des.final

    degenerate = OpenSSL::PKCS7.new degenerate
    assert_equal degenerate.certificates.size, 1
    assert_equal degenerate.recipients, []
    assert_equal degenerate.signers, []

    new_cert = degenerate.certificates.first
    assert new_cert.check_private_key(csr_key)

  end

end

