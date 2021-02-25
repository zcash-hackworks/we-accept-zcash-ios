use_frameworks!
target 'accept-zcash-poc' do 
  pod 'ZcashLightClientKit', :git => 'https://github.com/zcash/ZcashLightClientKit.git', :branch => 'key-validation'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|


      if target.name == 'ZcashLightClientKit'
         config.build_settings['ZCASH_NETWORK_ENVIRONMENT'] = ENV["ZCASH_NETWORK_ENVIRONMENT"]
      end
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
