#
# Be sure to run `pod lib lint RockSchedule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RockSchedule'
  s.version          = '0.1.0'
  s.summary          = '掌上重邮·课表相关'
  s.description      = <<-DESC
  Swift Schedule for iOS 掌上重邮 ⓒRedrock Staff
                       DESC
                       
     
  s.swift_versions = ['5']
  s.homepage         = 'https://github.com/RisingSSR/RockSchedule'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RisingSSR' => '2769119954@qq.com' }
  s.source           = { :git => 'https://github.com/RisingSSR/RockSchedule.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  
  
  # LinkedList
  s.subspec 'LinkedList' do |list|
      list.source_files = 'RockSchedule/Classes/LinkedList/**/*.swift'
  end
  
  # OrderedSet
  s.subspec 'OrderedSet' do |orderedSet|
      orderedSet.source_files = 'RockSchedule/Classes/OrderedSet/**/*.swift'
  end
  
  # CountedSet
  s.subspec 'CountedSet' do |countedSet|
      countedSet.source_files = 'RockSchedule/Classes/CountedSet/**/*.swift'
  end
  
  # Foundation扩展
  s.subspec 'Extension' do |extension|
      extension.source_files = 'RockSchedule/Classes/Extension/**/*.swift'
  end
  
  # 坐标点协议
  s.subspec 'Locate' do |locate|
      locate.source_files = 'RockSchedule/Classes/DataSource/Locate.swift'
  end
  
  # 数据请求
  s.subspec 'Request' do |request|
      request.source_files = 'RockSchedule/Classes/DataSource/Request.swift'
      request.dependency 'RockSchedule/CacheData'
      request.dependency 'SwiftyJSON'
      request.dependency 'Alamofire'
  end
  
  # 数据缓存
  s.subspec 'CacheData' do |cacheData|
      cacheData.source_files =
        'RockSchedule/Classes/DataSource/Cache.swift',
        'RockSchedule/Classes/DataSource/CombineItem.swift',
        'RockSchedule/Classes/DataSource/Course.swift',
        'RockSchedule/Classes/DataSource/Key.swift'
      cacheData.dependency 'SwiftyJSON'
      cacheData.dependency 'WCDB.swift'
  end
  
  # 数据处理
  s.subspec 'Solve' do |solve|
      solve.source_files =
        'RockSchedule/Classes/DataSource/Map.swift',
        'RockSchedule/Classes/DataSource/DoubleMap.swift'
      solve.dependency 'RockSchedule/LinkedList'
      solve.dependency 'RockSchedule/CacheData'
  end
  
  # 视图
  s.subspec 'Views' do |views|
      views.source_files = 'RockSchedule/Classes/Views/**/*.swift'
      views.resource = ['RockSchedule/Assets/Schedule/*.xcassets']
  end
  
  # 布局
  s.subspec 'Layout' do |layout|
      layout.source_files = 'RockSchedule/Classes/Layout/**/*.swift'
  end
  
  # 数据交互
  s.subspec 'Service' do |transform|
      transform.source_files = 'RockSchedule/Classes/Service/**/*.swift'
      transform.dependency 'RockSchedule/Solve'
      transform.dependency 'RockSchedule/Layout'
      transform.dependency 'RockSchedule/Views'
  end
  
  #s.resource_bundles = {
  #    'RockSchedule' => ['RockSchedule/Assets/Schedule/*.xcassets']
  #}
  
end
