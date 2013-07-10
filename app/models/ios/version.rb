class Ios::Version

  include Comparable
  
  IOS = {}

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
      humanized_beta <=> other_version.humanized_beta
    else
      raw_patch_diff = patch <=> other_version.patch
      return raw_patch_diff unless raw_patch_diff == 0
      beta <=> other_version.beta
    end
  end
  
  def beta?
    !!@is_beta
  end
  
  def guessed?
    !!@guessed
  end
  
end
