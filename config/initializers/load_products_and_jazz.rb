Product::Products = YAML.load File.read(File.join(Rails.root, 'db', 'products.yml'))
Ios::Version::IOS = YAML.load File.read(File.join(Rails.root, 'db', 'ios_versions.yml'))
