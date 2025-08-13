require 'json'

def flutter_root
  generated_xcode_build_settings = parse_KV_file(File.join('..', 'Flutter', 'Generated.xcconfig'))
  if generated_xcode_build_settings.empty?
    raise "Generated.xcconfig must exist. Make sure `flutter packages get` is executed in the project directory."
  end
  generated_xcode_build_settings['FLUTTER_ROOT']
end

def parse_KV_file(file_path)
  file_path = File.expand_path(file_path)
  return {} unless File.exist?(file_path)
  
  result = {}
  File.foreach(file_path) do |line|
    next if line.start_with?('#')
    key, value = line.split('=', 2).map(&:strip)
    result[key] = value.gsub('"', '') if key && value
  end
  result
end

def install_all_flutter_pods(flutter_application_path)
  flutter_application_path = File.expand_path(flutter_application_path)
  flutter_root = File.expand_path(flutter_root)
  
  Dir.chdir(flutter_application_path) do
    if !File.exist?('ios') || !File.directory?('ios')
      raise "iOS directory not found: #{flutter_application_path}/ios"
    end

    # Copia archivos necesarios
    FileUtils.cp_r('ios/Flutter', '.ios/') rescue nil
  end
end