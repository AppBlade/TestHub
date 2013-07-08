class Product

  Products = {
    MacBookPro: {
      name: 'MacBook Pro',
      models: {

      }
    },
    MacBookAir: {
      name: 'MacBook Air',
      models: {

      }
    },
    iMac: {
      name: 'iMac',
      models: {

      }
    },
    Macmini: {
      name: 'Mac mini',
      models: {

      },
    },
    MacPro: {
      name: 'Mac pro',
      models: {

      }
    },
    MacBook: {
      name: 'MacBook',
      models: {

      }
    },
    iPhone: {
      name: 'iPhone',
      models: { 
        '1,1'  => ['1',   'armv6',  %w(telephony wifi sms still-camera accelerometer location-services microphone opengles-1 armv6)],
        '1,2'  => ['3G',  'armv6',  %w(telephony wifi sms still-camera accelerometer location-services gps microphone opengles-1 armv6 peer-peer)],
        '1,2*' => ['3G',  'armv6',  %w(telephony wifi sms still-camera accelerometer location-services gps microphone opengles-1 armv6 peer-peer)],
        '2,1'  => ['3GS', 'armv7',  %w(telephony wifi sms still-camera auto-focus-camera video-camera accelerometer location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,1*' => ['3GS', 'armv7',  %w(telephony sms still-camera auto-focus-camera video-camera accelerometer location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '3,1'  => ['4',   'armv7',  %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '3,2'  => ['4',   'armv7',  %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '3,3'  => ['4',   'armv7',  %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '4,1'  => ['4S',  'armv7',  %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '5,1'  => ['5',   'armv7s', %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '5,2'  => ['5',   'armv7s', %w(telephony wifi sms still-camera auto-focus-camera front-facing-camera camera-flash video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)]
      }
    },
    iPad: {
      name: 'iPad',
      models: {
        '1,1' => ['1', 'armv7', %w(wifi accelerometer location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,1' => ['2', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,2' => ['2', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,3' => ['2', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,4' => ['2', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '2,5' => ['Mini', 'armv7', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '2,6' => ['Mini', 'armv7', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '2,7' => ['Mini', 'armv7', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,1' => ['3', 'armv7',  %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,2' => ['3', 'armv7',  %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,3' => ['3', 'armv7',  %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,4' => ['4', 'armv7s', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,5' => ['4', 'armv7s', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        '3,6' => ['4', 'armv7s', %w(wifi still-camera auto-focus-camera front-facing-camera video-camera accelerometer gyroscope location-services gps magnetometer gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)]
      }
    },
    iPod: {
      name: 'iPod Touch',
      models: {
        '1,1' => ['1', 'armv6', %w(wifi accelerometer location-services opengles-1 armv6)],
        '2,1' => ['2', 'armv6', %w(wifi accelerometer location-services gamekit microphone opengles-1 armv6 peer-peer)],
        '3,1' => ['3', 'armv7', %w(wifi accelerometer location-services gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '4,1' => ['4', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer)],
        '5,1' => ['5', 'armv7', %w(wifi still-camera auto-focus-camera camera-flash front-facing-camera video-camera accelerometer gyroscope location-services gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)],
        'FCJ' => ['5', 'armv7', %w(wifi still-camera front-facing-camera video-camera accelerometer gyroscope location-services gamekit microphone opengles-1 opengles-2 armv6 armv7 peer-peer bluetooth-le)]
      }
    }
  }

  attr_reader :family, :model_number, :model, :cpu, :capabilities, :name

  def initialize(product_name, serial = '')
    family, family_information = Products.select do |family|
      product_name =~ /^#{family}/
    end.first
    @family = family.to_s
    model_match = family_information[:models].select do |model_number|
      serial.last(3) == model_number
    end.first
    model_match ||= family_information[:models].select do |model_number|
      product_name == "#{family}#{model_number}"
    end.first
    @model_number, (@model, @cpu, @capabilities) = model_match
    @name = "#{@family} #{@model}"
  end

  def to_s
    name
  end

end
