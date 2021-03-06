module GirFFI
  # Base class for all generated classes of type :object.
  class ObjectBase < ClassBase
    # Wrap the passed pointer in an instance of its type's corresponding class,
    # generally assumed to be a descendant of the current type.
    def self.wrap ptr
      ptr.to_object
    end

    #
    # Find property info for the named property.
    #
    # @param name The property's name
    #
    # @return [GObjectIntrospection::IPropertyInfo] The property's info
    #
    def self.find_property name
      gir_ffi_builder.find_property name
    end

    #
    # Find signal info for the named signal.
    #
    # @param name The signal's name
    #
    # @return [GObjectIntrospection::ISignalInfo] The signal's info
    #
    def self.find_signal name
      gir_ffi_builder.find_signal name
    end

    # @deprecated Use #to_ffi_type instead. Will be removed in 0.8.0.
    def self.to_ffitype
      to_ffi_type
    end

    def self.to_ffi_type
      :pointer
    end

    def self.copy_value_to_pointer value, pointer, offset = 0
      pointer.put_pointer offset, value.to_ptr
    end

    def self.object_class
      gir_ffi_builder.object_class
    end
  end
end
