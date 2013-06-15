require 'gir_ffi/builder/type/registered_type'

module GirFFI
  module Builder
    module Type

      # Implements the creation of an enum or flags type. The type will be
      # attached to the appropriate namespace module, and will be defined
      # as an enum for FFI.
      class Enum < RegisteredType
        private

        def enum_sym
          @classname.to_sym
        end

        def value_spec
          return info.values.map {|vinfo|
            val = GirFFI::ArgHelper.cast_uint32_to_int32(vinfo.value)
            [vinfo.name.to_sym, val]
          }.flatten
        end

        def instantiate_class
          @klass = optionally_define_constant namespace_module, @classname do
            lib.enum(enum_sym, value_spec)
          end
          unless already_set_up
            setup_gtype_getter
            setup_inspect
          end
        end

        def setup_inspect
          @klass.instance_eval <<-EOS
            def self.inspect
              "#{@namespace}::#{@classname}"
            end
          EOS
        end

        def already_set_up
          @klass.respond_to? :get_gtype
        end
      end
    end
  end
end

