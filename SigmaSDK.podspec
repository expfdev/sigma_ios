Pod::Spec.new do |s|  
    s.name              = 'SigmaSDK'
    s.version           = '1.3.3'
    s.summary           = 'Experimentation tool from EXPF'
    s.homepage          = 'https://expf.ru/sigma/'

    s.author            = { 'Expf Dev' => 'dev@expf.ru' }
    s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

    s.platform          = :ios
    s.source            = { :git => 'https://github.com/expfdev/sigma_ios.git', :tag => '1.3.3' }

    s.vendored_frameworks = 'SigmaSDK.xcframework'
    s.ios.deployment_target = '11.0'
end  