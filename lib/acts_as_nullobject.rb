module Plugin #:nodoc:
  module Acts #:nodoc:
    
    # Specify this act if you want use NullObject pattern.
    #
    #   class User < ActiveRecord::Base
    #     acts_as_nullobject
    #   end
    #
    # See <tt>TicketSolve::Acts::NullObject::ClassMethods#acts_as_nullobject</tt>
    # for configuration options
    module NullObject #:nodoc:
      
      def self.included(base) #:nodoc:
        base.extend ClassMethods
      end
      
      module ClassMethods
        
        # == Configuration options
        #
        # * <tt>initials</tt> - Initial attributes for NullObject instance
        #
        #   You can add to those by passing one or an array of fields to skip.
        #
        #     class User < ActiveRecord::Base
        #       acts_as_nullobject :name => 'Annonymous'
        #     end
        # 
        def acts_as_nullobject(initials = {}, &block)
          # don't allow multiple calls
          return if self.included_modules.include?(Plugin::Acts::NullObject::InstanceMethods)
          include Plugin::Acts::NullObject::InstanceMethods
          
          # Alternative implementation of creating new Class on the fly
          #klass = Class.new self
          #Object.const_set "Null#{self}", klass
          
          instance_methods = initials.delete(:instance_methods) || ""
          
          block.call(initials) unless block.nil?
          
          Object.class_eval <<-EOF
            class Null#{self} < #{self}
              before_destroy :cant_delete_nullobject
              def cant_delete_nullobject; return deleteable?; end
              def deleteable; return false; end
              def deleteable?; return deleteable; end
              
                            
              def to_xml_with_is_null_object(options = {}, &block)
                proc = Proc.new { |options| options[:builder].tag!('is_null_object', is_null_object, { :type => 'boolean' }) }
                procs = [proc]
                procs << block unless block.nil?
                to_xml_without_is_null_object({:procs => procs}.merge(options))
              end
              alias_method_chain :to_xml, :is_null_object

              #{instance_methods}
            end
          EOF
          
          class_eval <<-EOF
            extend Plugin::Acts::NullObject::SingletonMethods

            def is_null_object?()
              self.is_a?(Null#{self})
            end
            alias :is_null_object :is_null_object?

            def self.null_object(account_id = nil)
              null_obj = self.find(:first, :conditions => { :type => 'Null#{self}' })
              return null_obj unless null_obj.nil?
              
              initials = #{initials.inspect}
              
              Null#{self}.create!(initials)
            end
          EOF
          
        end
      end
      
      module InstanceMethods
      end
      
      module SingletonMethods
      end
      
    end
    
  end
end