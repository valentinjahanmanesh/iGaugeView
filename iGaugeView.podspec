Pod::Spec.new do |s|
  s.name             = 'iGaugeView'
  s.version          = '0.1.0'
  s.summary          = 'iGaugeView is a small library to create and display Gauge graphs.'
 
  s.description      = <<-DESC
iGaugeView is a small library to create and display Gauge graphs. It is fully customizable: you can set the color, size, text and many other properties of the graph.
 
  s.homepage         = 'https://github.com/farshadjahanmanesh/iGaugeView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'farshad jahanmanesh' => 'farshadjahanmanesh@gmail.com' }
  s.source           = { :git => 'https://github.com/farshadjahanmanesh/iGaugeView.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '10.0'
  s.source_files = 'iGaugeView/iGaugeView.swift'
 
end