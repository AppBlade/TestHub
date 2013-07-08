class Ios::Version

  include Comparable
  
  IOS = {
    '7' => [
      3, {
        'D' => [[1, 2]],
        'E' => [[1, 3]],
        'B' => [
          2, {
            '367' => [0],
            '500' => [2]
          }
        ]
      }
    ],
    '8' => [
      4, {
        'A' => [
          0, {
            '293' => [0],
            '306' => [1],
            '400' => [2]
          }
        ],
        'B' => [
          1, {
            '5080c' => [0, 1],
            '5091b' => [0, 2],
            '117' => [0],
          }
        ],
        'C' => [
          2, {
            '5091e' => [0, 1],
            '5101c' => [0, 2],
            '5115c' => [0, 3],
            '134'   => [0],
          	'134b'  => [0],
          	'148'   => [1],
          	'148a'  => [1]
          }
        ],
        'E' => [
          2, {
            '128'   => [5],
          	'200'   => [6],
          	'303'   => [7],
          	'401'   => [8],
          	'501'   => [9],
          	'600'   => [10],
          }
        ],
        'F' => [
          3, {
            '5148b' => [0, 1],
          	'5153d' => [0, 2],
          	'5166b' => [0, 3],
          	'190'   => [0],
          	'191'   => [0],
          }
        ],
        'G' => [
          3, {
            '4' => [1]
          }
        ],
        'H' => [
          3, {
            '7' => [2],
          	'8' => [2],
          }
        ],
        'J' => [
          3, {
            '2' => [3],
          	'3' => [3],
          }
        ],
        'K' => [
          3, {
            '2' => [4],
          }
        ],
        'L' => [
          3, {
            '1' => [5],
          }
        ]
      }
    ],
    '9' => [
      5, {
        'A' => [
          0, {
            '5220p' => [0, 1],
        	  '5248d' => [0, 2],
        	  '5258f' => [0, 3],
        	  '5274d' => [0, 4],
        	  '5288d' => [0, 5],
        	  '5302b' => [0, 6],
        	  '5313e' => [0, 7],
        	  '334'   => [0],
        	  '402'   => [1, 1],
          	'404'   => [1, 2],
          	'405'   => [1],
          	'406'   => [1]
        	}
    	  ],
    	  'B' => [
    	    1, {
    	      '5117b' => [0, 1],
        	  '5127c' => [0, 2],
        	  '5141a' => [0, 3],
        	  '176'   => [0],
        	  '179'   => [0],
        	  '206'   => [1],
        	  '208'   => [1]
        	}
    	  ]
      }
    ],
    '10' => [
      6, {
        'A' => [
          0, {
            '5316k' => [0, 1],
          	'5338d' => [0, 2],
          	'5355d' => [0, 3],
          	'5376e' => [0, 4],
            '403'   => [0],
            '405'   => [0],
          	'406'   => [0],
          	'407'   => [0],
          	'523'   => [1],
          	'525'   => [1],
            '8426'  => [1],
            '550'   => [2],
            '551'   => [2],
            '8500'  => [2],
          }
        ],
        'B' => [
          1, {
            '5095f' => [0, 1],
            '5105c' => [0, 2],
            '5117b' => [0, 3],
            '5126b' => [0, 4],
            '141'   => [0],
            '142'   => [0],
            '143'   => [0],
            '144'   => [0],
            '311'   => [1, 1],
            '145'   => [1],
            '146'   => [2],
            '147'   => [2],
            '318'   => [3, 2],
            '329'   => [3],
            '350'   => [4],
          }
        ]
      }
    ],
    '11' => [
      7, {
        'A' => [
          0, {
            '4372q' => [0, 1],
            '4400f' => [0, 2]
          }
        ]
      }
    ]
  }

  attr_accessor :build, :major, :humanized_major, :minor, :humanized_minor, :patch, :humanized_patch, :beta, :humanized_beta
  
  def initialize(build)
    @build = build
    if build =~ /([1-9][0-9]*)\.([0-9]+)(?:\.([0-9]+))?/
      @humanized_major, @humanized_minor, @humanized_patch = $1.to_i, $2.to_i, $3.to_i
      @is_beta = true
      @humanized_beta = 0
    else
      build =~ /([1-9][0-9]*)([A-Z])(\d+)([a-z]*)/
      @major, @minor, @patch, @beta = $1.to_i, $2, $3.to_i, $4
      built_version = []
      if IOS[major.to_s]
        built_version << IOS[major.to_s][0]
        built_version << (IOS[major.to_s][1][minor.to_s] && IOS[major.to_s][1][minor.to_s][0])
        built_version << (IOS[major.to_s][1][minor.to_s] && IOS[major.to_s][1][minor.to_s][1] && IOS[major.to_s][1][minor.to_s][1]["#{patch}#{beta}"])
      end
      built_version.flatten!
      @humanized_major, @humanized_minor, @humanized_patch, @humanized_beta = built_version
      @is_beta ||= !@humanized_beta.nil?
      @humanized_major ||= @guessed = true && major - 4
      @humanized_minor ||= @guessed = true && minor.ord - 65
      @humanized_patch ||= @guessed = true && 0
    end
  end
  
  def to_s
    humanized_major && humanized_minor && "#{humanized_major}.#{humanized_minor}#{".#{humanized_patch}" if humanized_patch}#{"b#{humanized_beta}" if humanized_beta && humanized_beta > 0}".gsub(/\.0$/, '').gsub(/\.0b/, "b") || build
  end
  
  def <=>(other_version)
    major_diff = humanized_major <=> other_version.humanized_major
    return major_diff unless major_diff == 0
    minor_diff = humanized_minor <=> other_version.humanized_minor
    return minor_diff unless minor_diff == 0
    patch_diff = humanized_patch <=> other_version.humanized_patch
    return patch_diff unless patch_diff == 0
    if beta? || other_version.beta?
      return -1 if beta? && !other_version.beta?
      return 1 if !beta? && other_version.beta?
      beta_diff = humanized_beta <=> other_version.humanized_beta
      return beta_diff unless beta_diff == 0
      return beta <=> other_version.beta
    else
      raw_patch_diff = patch <=> other_version.patch
      return raw_patch_diff unless raw_patch_diff == 0
      return beta <=> other_version.beta
    end
  end
  
  def beta?
    !!@is_beta
  end
  
  def guessed?
    !!@guessed
  end
  
end
