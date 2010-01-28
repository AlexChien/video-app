class User < ActiveRecord::Base

  named_scope :being, lambda { |state|
    { :conditions => { :state => state } }
  }

  acts_as_authentic
  
  # acl9插件的subject模型
  acts_as_authorization_subject
  
  
end
