require 'test_helper'

class Ios::VersionTest < ActiveSupport::TestCase

  KnownIosVersions = {
    '7D11'    => '3.1.2',
  	'7E18'    => '3.1.3',
    '7B367'   => '3.2',
  	'7B500'   => '3.2.2',
    '8A293'   => '4.0',
  	'8A306'   => '4.0.1',
  	'8A400'   => '4.0.2',
  	'8B5080c' => '4.1b1',
  	'8B5091b' => '4.1b2',
  	'8B117'   => '4.1',
  	'8C5115c' => '4.2b3',
  	'8C134'   => '4.2',
  	'8C134b'  => '4.2',
  	'8C148'   => '4.2.1',
  	'8C148a'  => '4.2.1',
  	'8E128'   => '4.2.5',
  	'8E200'   => '4.2.6',
  	'8E303'   => '4.2.7',
  	'8E401'   => '4.2.8',
  	'8E501'   => '4.2.9',
  	'8E600'   => '4.2.10',
  	'8F5148b' => '4.3b1',
  	'8F5153d' => '4.3b2',
  	'8F5166b' => '4.3b3',
  	'8F190'   => '4.3',
  	'8F191'   => '4.3',
  	'8G4'     => '4.3.1',
  	'8H7'     => '4.3.2',
  	'8H8'     => '4.3.2',
  	'8J2'     => '4.3.3',
  	'8J3'     => '4.3.3',
  	'8K2'     => '4.3.4',
  	'8L1'     => '4.3.5',
  	'9A5220p' => '5.0b1',
  	'9A5248d' => '5.0b2',
  	'9A5258f' => '5.0b3',
  	'9A5274d' => '5.0b4',
  	'9A5288d' => '5.0b5',
  	'9A5302b' => '5.0b6',
  	'9A5313e' => '5.0b7',
  	'9A334'   => '5.0',
  	'9A402'   => '5.0.1b1',
  	'9A404'   => '5.0.1b2',
  	'9A405'   => '5.0.1',
  	'9A406'   => '5.0.1',
  	'9B5117b' => '5.1b1',
  	'9B5127c' => '5.1b2',
  	'9B5141a' => '5.1b3',
  	'9B176'   => '5.1',
  	'9B179'   => '5.1',
  	'9B206'   => '5.1.1',
  	'9B208'   => '5.1.1',
  	'10A5316k' => '6.0b1',
  	'10A5338d' => '6.0b2',
  	'10A5355d' => '6.0b3',
  	'10A5376e' => '6.0b4',
    '10A403'   => '6.0',
    '10A405'   => '6.0',
  	'10A406'   => '6.0',
  	'10A407'   => '6.0',
  	'10A523'   => '6.0.1',
  	'10A525'   => '6.0.1',
    '10A8426'  => '6.0.1',
    '10A550'   => '6.0.2',
    '10A551'   => '6.0.2',
    '10A8500'  => '6.0.2',
    '10B5105c' => '6.1b2',
    '10B5117b' => '6.1b3',
    '10B5126b' => '6.1b4',
    '10B141'   => '6.1',
    '10B142'   => '6.1',
    '10B143'   => '6.1',
    '10B144'   => '6.1',
    '10B311'   => '6.1.1b1',
    '10B145'   => '6.1.1',
    '10B146'   => '6.1.2',
    '10B147'   => '6.1.2',
    '10B318'   => '6.1.3b2',
    '10B329'   => '6.1.3',
    '10B350'   => '6.1.4',
    '11A4372q' => '7.0b1',
    '11A4400f' => '7.0b2'
  }

  test 'test stringification of known versions' do
    KnownIosVersions.each do |known_ios_build, humanized_version|
      Ios::Version.new(known_ios_build).tap do |ios_version|
        assert_equal humanized_version, ios_version.to_s, ios_version.build
      end
    end
  end
  
  test 'test guess of known versions' do
    KnownIosVersions.each do |known_ios_build, humanized_version|
      Ios::Version.new(known_ios_build).tap do |ios_version|
        assert !ios_version.guessed?, "#{ios_version.build} should be known"
      end
    end 
  end
  
  test 'test order of known versions' do
    KnownIosVersions.map do |known_ios_build, humanized_version|
      Ios::Version.new(known_ios_build)
    end.shuffle.sort.each_with_index do |ios_version, index|
      assert_equal index, KnownIosVersions.keys.index(ios_version.build), "#{ios_version.build} <=> #{KnownIosVersions.keys[index]}"
    end
  end

  GuessedVersions = {
    '10A408'   => '6.0',
    '10A8501'  => '6.0',
    '10B351'   => '6.1',
    '10C351'   => '6.2',
    '11A459'   => '7.0',
    '11A4372r' => '7.0',
    '11B345'   => '7.1',
    '12A234'   => '8.0'
  }
  
  test 'test stringification of guessed versions' do
    GuessedVersions.each do |made_up_ios_build, humanized_version|
      Ios::Version.new(made_up_ios_build).tap do |ios_version|
        assert_equal humanized_version, ios_version.to_s, made_up_ios_build
      end
    end
  end

  test 'test guess of guessed versions' do
    GuessedVersions.each do |made_up_ios_build, humanized_version|
      Ios::Version.new(made_up_ios_build).tap do |ios_version|
        assert ios_version.guessed?, "#{ios_version.build} should be a guess"
      end
    end
  end
  
  test 'test order of guessed versions' do
    GuessedVersions.map do |made_up_ios_build, humanized_version|
      Ios::Version.new(made_up_ios_build)
    end.shuffle.sort.each_with_index do |ios_version, index|
      assert_equal index, GuessedVersions.keys.index(ios_version.build), "#{ios_version.build} <=> #{GuessedVersions.keys[index]}"
    end
  end

end
