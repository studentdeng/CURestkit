def import_pods
  pod 'ASIHTTPRequest', '~> 1.8.1'
end

Pod::Spec.new do |s|
  s.name         = "CURestKit"
  s.version      = "1.0.2"
  s.summary      = "A short description of CURestKit."

  s.description  = <<-DESC
                   A longer description of CURestKit in Markdown format.
                   DESC

  s.homepage     = "https://github.com/studentdeng/CURestkit"
  s.license      = 'MIT'
  s.author       = { "curer" => "studentdeng@hotmail.com" }
  s.platform     = :ios, '5.0'

  s.source       = { :git => "https://github.com/studentdeng/CURestkit.git", :tag => s.version.to_s }
  s.source_files  = 'CURestkit', 'CURestkit/**/*.{h,m}'
  s.requires_arc = true
end