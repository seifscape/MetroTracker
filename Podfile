platform :ios, '11.1'
inhibit_all_warnings!
use_frameworks!

def shared_pods
    pod 'SPPermission'
    pod 'Alamofire'
    pod 'PromiseKit'
    pod 'CodableAlamofire'
end

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'DC Metro' do
    shared_pods
end

target 'DC MetroTests' do
    shared_pods
    testing_pods
end

target 'DC MetroUITests' do
end
