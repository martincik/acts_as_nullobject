require 'acts_as_nullobject'
require 'belongs_to_with_nullobject'
require 'deleteable'

ActiveRecord::Base.send :include, Plugin::Acts::NullObject
ActiveRecord::Base.send :include, Plugin::BelongsToWith::NullObject
ActiveRecord::Base.send :include, Plugin::Extensions::Deleteable