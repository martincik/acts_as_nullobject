module Plugin #:nodoc:
  module Extensions #:nodoc:
    
    # Adds new deleteable method to ActiveRecord::Base class
    #
    #   class User < ActiveRecord::Base
    #     attr_reader :deleteable 
    #
    #     def deleteable?
    #       deleteable.nil? ? true : deleteable
    #     end   
    #
    #   end
    #
    # See <tt>TicketSolve::Acts::NullObject::ClassMethods#acts_as_nullobject</tt>
    # for configuration options
    module Deleteable #:nodoc:
      
      def self.included(base) #:nodoc:
        base.extend ClassMethods
        base.send(:include, InstanceMethods)
      end
      
      module ClassMethods
        def deleteable?
          true
        end
      end
      
      module InstanceMethods
        def deleteable?
          deleteable.nil? ? self.class.deleteable? : deleteable
        end
        
        def deleteable
          read_attribute('deleteable').nil? ? true : read_attribute('deleteable')
        end
        
        def deleteable=(_value)
          write_attribute('deleteable', _value)
        end
      end
      
    end #Deleteable
    
  end #Extension
  
end