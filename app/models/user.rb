class User < ActiveRecord::Base

  acts_as_authentic
  
  # acl9插件的subject模型
  acts_as_authorization_subject
  
end
