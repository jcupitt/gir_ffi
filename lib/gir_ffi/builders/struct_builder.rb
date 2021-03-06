require 'gir_ffi/builders/registered_type_builder'
require 'gir_ffi/builders/with_layout'
require 'gir_ffi/struct_base'

module GirFFI
  module Builders
    # Implements the creation of a class representing a Struct.
    class StructBuilder < RegisteredTypeBuilder
      include WithLayout

      private

      def setup_class
        setup_layout
        setup_constants
        stub_methods
        setup_field_accessors
        provide_constructor
      end

      # FIXME: Private method only in subclass
      def layout_superclass
        FFI::Struct
      end

      def superclass
        StructBase
      end
    end
  end
end
