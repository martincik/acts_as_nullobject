module Plugin #:nodoc:
  module BelongsToWith #:nodoc:
    
    # Specify this act if you want use NullObject pattern.
    #
    #   class User < ActiveRecord::Base
    #     has_many_with_nullobject   :roles
    #     has_one_with_nullobject    :role
    #     belongs_to_with_nullobject :account
    #   end
    #
    module NullObject #:nodoc:
      
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end
      
      module ClassMethods
        # == Configuration options
        #
        #   You can add to those by passing one or an array of fields to skip.
        #
        #     class User < ActiveRecord::Base
        #       belongs_to_with_nullobject :account
        #     end
        # 
        def belongs_to_with_nullobject(association_id, options = {})
          
          class_inheritable_reader :null_object_enabled
          
          if options[:class_name]
            class_name = options[:class_name]
          else
            class_name = association_id.to_s.classify
          end
          
          class_eval <<-EOF
            extend Plugin::BelongsToWith::NullObject::SingletonMethods
          
            belongs_to(association_id, options)
            
            def #{association_id.to_s}_with_nullobject
              association = #{association_id.to_s}_without_nullobject 
              if association.nil? && null_object_enabled
                self.#{association_id.to_s} = #{class_name}.null_object
              end
              #{association_id.to_s}_without_nullobject
            end
            alias_method_chain :#{association_id.to_s}, :nullobject
            
            before_save :sanitize_#{association_id.to_s}_attribute
            def sanitize_#{association_id.to_s}_attribute
              #{association_id.to_s}_with_nullobject
            end
            
            write_inheritable_attribute :null_object_enabled, true
          EOF
    
        end
        
      end
            
      module SingletonMethods
        
        def enable_null_object
          write_inheritable_attribute :null_object_enabled, true
        end
        
        def disable_null_object
          write_inheritable_attribute :null_object_enabled, false
        end
        
      end
      
    end
    
  end
end