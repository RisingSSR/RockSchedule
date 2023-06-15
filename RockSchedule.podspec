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
  s.deployment_target = '11.0'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  
  # 作为第三方库使用
  
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
  
  # LRUCache
  s.subspec 'LRUCache' do |lruCache|
      lruCache.source_files = 'RockSchedule/Classes/LRUCache/**/*.swift'
  end
  
  # VCTransitioningDelegate
  s.subspec 'VCTransitioningDelegate' do |vcTransitioningDelegate|
      vcTransitioningDelegate.source_files = 'RockSchedule/Classes/VCTransitioningDelegate/**/*.swift'
  end

  # R.swift
  s.subspec 'RSwift' do |rSwift|
      rSwift.dependency 'R.swift'
      rSwift.resources = "RockSchedule/Assets/*.xcassets"
      rSwift.script_phases = [{
          :name => 'R',
          :script => '"$PODS_ROOT/R.swift/rswift" generate "$SRCROOT/../RockSchedule/Classes/R.generated.swift"',
          :execution_position => :before_compile,
          :input_files => ["$TEMP_DIR/rswift-lastrun"],
          :output_files => ["$SRCROOT/../RockSchedule/Classes/R.generated.swift"]
      }]
  end
  
  
  # 正常的东西
  
  # RyNetManager
  s.subspec 'RyNetManager' do |ryNetManager|
      ryNetManager.source_files = 'RockSchedule/Classes/RyNetManager/**/*.swift'
      ryNetManager.dependency 'SwiftyJSON'
      ryNetManager.dependency 'Alamofire'
  end
  
  # Extension扩展
  s.subspec 'Extension' do |extension|
      extension.subspec 'Foundation' do |foundation|
          foundation.source_files = 'RockSchedule/Classes/Extension/FoundationExtension.swift'
      end
      extension.subspec 'UIKit' do |uikit|
          uikit.source_files = 'RockSchedule/Classes/Extension/UIKitExtension.swift'
      end
  end
  
  # 坐标点协议
  s.subspec 'Locate' do |locate|
      locate.source_files = 'RockSchedule/Classes/DataSource/Locate.swift'
  end
  
  # 数据请求
  s.subspec 'Request' do |request|
      request.source_files = 'RockSchedule/Classes/DataSource/Request.swift'
      request.dependency 'RockSchedule/CacheData'
      request.dependency 'RockSchedule/RyNetManager'
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
      cacheData.dependency 'RockSchedule/Extension/Foundation'
      cacheData.dependency 'RockSchedule/LRUCache'
  end
  
  # 数据处理
  s.subspec 'Solve' do |solve|
      solve.source_files =
        'RockSchedule/Classes/DataSource/TimeLine.swift',
        'RockSchedule/Classes/DataSource/Map.swift',
        'RockSchedule/Classes/DataSource/FinalMap.swift'
      solve.dependency 'RockSchedule/LinkedList'
      solve.dependency 'RockSchedule/CacheData'
  end
  
  # 视图
  s.subspec 'Views' do |views|
      views.source_files = 'RockSchedule/Classes/Views/**/*.swift'
      views.dependency 'RockSchedule/RSwift'
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
  #    'RockSchedule' => ['RockSchedule/Assets/*.xcassets']
  #}
  
end
