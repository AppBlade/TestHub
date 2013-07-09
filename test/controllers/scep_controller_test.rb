require 'test_helper'

class ScepControllerTest < ActionController::TestCase

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
   
    raw_message = Base64.decode64 <<DATA
MIIKYAYJKoZIhvcNAQcCoIIKUTCCCk0CAQExCzAJBgUrDgMCGgUAMIIEzQYJ
KoZIhvcNAQcBoIIEvgSCBLowggS2BgkqhkiG9w0BBwOgggSnMIIEowIBADGC
ArswggK3AgEAMIGeMIGQMQswCQYDVQQGEwJVUzEWMBQGA1UECBMNTWFzc2Fj
aHVzZXR0czEPMA0GA1UEBxMGQm9zdG9uMREwDwYDVQQKEwhSYWl6bGFiczER
MA8GA1UECxMIQXBwQmxhZGUxEDAOBgNVBAMTB1Rlc3RIdWIxIDAeBgkqhkiG
9w0BCQEWEWhlbHBAYXBwYmxhZGUuY29tAgkA5sStk4Dry9QwDQYJKoZIhvcN
AQEBBQAEggIAbd+VeHDxv0yDYVDPMPSilR5F9bgdJq/wbYCDmrDHiB6eZWMi
jq13ai5JyXNOkYFE4zyEYPKYTVt3g2gfs8lJ8n1YoY3jNFahVrnIr5XOAkuU
FotLHp7DDEP48zrOHUNEWQJ4ZRpN/GZaRfqCe040btsFLnHUNO/so1Yi19Zf
eavrFZ+0HlUB+JPODowsakis57KQkFkwUKP3mzblRk2mn1zO5QrtNBulYKfw
Xzx9vaDZz4J1ldZYcISjEDWWWP+oDs8LHewGvZWIwluvCrvQbYKLq5nKI2dB
AzAIsrK6XFkoxrhqeNYSyAubNQ+WCy1mAgBQDiNr9knT9RiU6g74FcorNBpY
N8sRUZt1jCxODiUZh+X1fZD1W1m41jnMNBS8/1ldZOmaCItcPKWhndPy5Q2S
eKnOgWmOdkDUsMhFTVKsg1rZl299v7LcVWVBNMC03SLBVQ8wQBfmaliVTFGp
gH5aS+ZEm4+p00fc2Uxfv9Ch1EBVXGP+59clWsXxXNVjOrHHN5lXNM1SA4eu
Ka+xVP2c1In9UWQ3sRnwgsTwe5H3as5vB9RHY5UvBaJpi2069nM7y22Kcm7R
b3/wZ1evekUXiWGWufRKsM8AdhHme8El+nOrw09PktRWHjWTmbcZTBGNuhJW
mZVqnTLIVkxT8Y3rEnvfljDQ1c0QpX2o+0UwggHdBgkqhkiG9w0BBwEwFAYI
KoZIhvcNAwcECOYD5nxm4Ro+gIIBuFaFLuIM0Lsr75CfG6de15vVrrSGxPgS
SE0Y6Z1EE3mR+P+gO9aey8Y5QvN1J1HkxCcaFWquhygmTKzkf+atRIEN4znk
lUdNF00ybjRzWTnN+Unh+3/3CNdooR0+mvN03bWgk5ZddWDxBHnej2fgNhFO
6oKT2Heuus7MnwYHDBqAo+vyd2ZzJd70lOi4bdlNAQt0jI76C0YHpBIN3cIB
2KULteHjAbxVVHQYCSskTuWEIsytap0nfsGkrQSUtMuqqTcHZbHvsNBqLc/Y
xK1LH4PEgRMhGMVKhczFWjvPHn29Z36KeZmCPjHtnRoBoqMQ1DfPwzZ1XTZ+
/YTYTAkSAeFqZWbP22VLllvDIpmiviL2rfkPsMpKlppcskt/XqZ/mMUGzFU8
M3IUJuaxZk7BFKjeJXYNwe8H5kksd0bvWBuh6SL1CCRsJis7h4QR+EW+1xOo
R1gAWFrbgN5PZQrzcsYsf9owK2TS7ykYSF20hzbDlJwGuDcmSYBEoojcONC+
duGDtIfdWVdgoJJfM0gFdJJp0k13+sju2TDVnIUUp1ndR4X0a0cX00vQyyGd
w8b7/rqUepsKP/sNoIIC9TCCAvEwggHZoAMCAQICAQEwCwYJKoZIhvcNAQEL
MCcxGDAWBgNVBAMMD01ETSBTQ0VQIFNJR05FUjELMAkGA1UEBhMCVVMwHhcN
MTMwNzA5MjEzMzQ3WhcNMTQwNzA5MjEzMzQ3WjAnMRgwFgYDVQQDDA9NRE0g
U0NFUCBTSUdORVIxCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAn8a//Du7pOYd5b9UtvozdoE933ma9bXX3ecTY9IoRrhB
tRirsUz+mYs+LGMlXtdhQIfRmLDfctRR9OkQ6NZE6d4gSAL6clB7J+YLZrrZ
BUn3GiSAG/bQBTIdhWNUujCwwFleGgKzmwLde/iGrqQUHzEkW1oukuCQdAev
81N0ifxVZgyCVzEprC2x+RRGWVO1CZ4tH5Q8hk4U5OggBK+U3PH7d/zPnTLb
CvuPG+hxOLoWLKTO/ymlSCNOSvlXAD65XP3p72tLRQVJ3UZJnPWxeqbFiG/S
MO3Nfqryby+eyJnXtaSffRocGbqhfvsg3cs7YdjOTDh249FZfHajY3fIqQID
AQABoyowKDAOBgNVHQ8BAf8EBAMCB4AwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
AwIwDQYJKoZIhvcNAQELBQADggEBAGVNlLfTmCQ69sfYnOjDq6fimet+HBnE
6rq39PdLEy4ybKGuDWdMTFWVLU92GZcFKynbGLm9QK2QM6/3jKviFY6ew+Qa
678w7QsRBLoIQN3DbQD8zqSUvG+6CYRBv7tDIIBwNffmrZZHifik4M/2yQjk
roKzkKRTwqxMaR9/Llv22rESfvwMGt2EkRSE03UTFHuyp3dNroZaxe+kKo/D
Md1KKKBNWuiN1dB/Vj0QuJyiWOe9WP+yDtV2xmk5s4H9GM/bMsL6FUbxfqLc
7Xg26GQvlfIPD1tm/imWPaOnxjS2aprvkqebMY/sMWx1zasSPkcwp45KA4F4
08HMRo5e/wAxggJvMIICawIBATAsMCcxGDAWBgNVBAMMD01ETSBTQ0VQIFNJ
R05FUjELMAkGA1UEBhMCVVMCAQEwCQYFKw4DAhoFAKCCARgwEgYKYIZIAYb4
RQEJAjEEEwIxOTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBgGCmCGSAGG
+EUBCQUxCgQIk++ol1Tycz8wHAYJKoZIhvcNAQkFMQ8XDTEzMDcwOTIxMzM0
N1owIwYJKoZIhvcNAQkEMRYEFJmrpHMb12VqLH6vJ6rTn6MJd0eoMDgGCmCG
SAGG+EUBCQcxKhMoMjEzMTU3ODRGQTA1OUVCRERGNDlDNTIxM0QzMTJCMzFG
NDYzQjA3RTBRBgkqhkiG9w0BCQcxRBNCMjpjZjMxYjYyZWNhMjQ2YzE1NGIy
NjI4NmM5ZGVjOTVjZTYxNTBhYzZlMTljMDQxYjZlOWQxNjY5MTBhZDM4ZmU0
MA0GCSqGSIb3DQEBAQUABIIBADTaHlhB3Iif9OssYtlOCd9zcXWwp41PPPOE
pBxXsx8sjmI6InXEnd/EBwaAsFKDtQP9wV4Tnr6tYv/d/kmdEVWKfYBnQGOQ
pcT54HBtaZPlK8Yp+hek9oOWgPTbNXSOGQOmYpOdl2RnFLCKoQeBp6UNQSM7
RZ9CfRl4Ucqv66jfX/WlDiu1YhLwLFVL2xmPeW77eoToxSr6necwhF4uBXJb
J22FZHWVvBo++BbCowEdNVI5MEq+YBn10gCWSpvqe+ri1TL/quDT4rLppGSK
3vBlBA+kISv71f2ZZFQxGn7Jnc1wp1Xc3i6cVpfM6fpqb689giT5G0wZEvPE
TxkwEAI=
DATA

    device = devices(:james_macbook)
    pki_message = OpenSSL::PKCS7.new raw_message

    post :pki_operation, raw_message.force_encoding('UTF-8'), content_type: 'application/octetstream'

    assert_response :success

    message = OpenSSL::PKCS7.new @response.body

    temp = Tempfile.new SecureRandom.hex
    temp.binmode
    temp.write message.to_der
    temp.close
    asn1parse = `openssl asn1parse -in #{temp.path} -inform DER`
    temp.unlink
    
    message_type_id = asn1parse.match(/OBJECT\s+:#{ScepController::MessageType   }\n.+\n.+PRINTABLESTRING\s+:(.+)/)[1]
    transaction_id  = asn1parse.match(/OBJECT\s+:#{ScepController::TransId       }\n.+\n.+PRINTABLESTRING\s+:(.+)/)[1]
    pki_status      = asn1parse.match(/OBJECT\s+:#{ScepController::PkiStatus     }\n.+\n.+PRINTABLESTRING\s+:(.+)/)[1]
    sender_nonce    = asn1parse.match(/OBJECT\s+:#{ScepController::SenderNonce   }\n.+\n.+OCTET STRING\s+\[HEX DUMP\]:(.+)/)[1]
    recipient_nonce = asn1parse.match(/OBJECT\s+:#{ScepController::RecipientNonce}\n.+\n.+OCTET STRING\s+\[HEX DUMP\]:(.+)/)[1]
    
    assert_equal message_type_id, '3'
    assert_equal transaction_id, '21315784FA059EBDDF49C5213D312B31F463B07E'
    assert_equal pki_status, '0'
    assert_equal recipient_nonce, '93EFA89754F2733F'
    assert       sender_nonce.present?

    assert message.certificates.nil?
    assert_equal message.recipients, []
    assert_equal message.signers.size, 1
    assert_equal message.signers.first.name, SCEPCert.subject
    assert_equal message.signers.first.serial, SCEPCert.serial

    assert message.verify [SCEPCert], SCEPStore, nil, OpenSSL::PKCS7::NOVERIFY

    message = OpenSSL::PKCS7.new message.data

    assert message.certificates.nil?
    assert_equal message.recipients.size, 1
    assert message.recipients.first.enc_key.present?

    assert_equal message.recipients.first.issuer.to_s, "/CN=MDM SCEP SIGNER/C=US"
    assert_equal message.signers, []
    
  end

end

