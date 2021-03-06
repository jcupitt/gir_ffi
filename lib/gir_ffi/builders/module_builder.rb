require 'gir_ffi/builder_helper'
require 'gir_ffi/module_base'
require 'gir_ffi/builders/function_builder'
require 'indentation'

module GirFFI
  module Builders
    # Builds a module based on information found in the introspection
    # repository.
    class ModuleBuilder
      include BuilderHelper

      def initialize namespace, version = nil
        @namespace = namespace
        @version = version
        # FIXME: Pass safe namespace as an argument
        @safe_namespace = @namespace.gsub(/^./, &:upcase)
      end

      def generate
        modul
      end

      def setup_method method
        go = function_introspection_data method.to_s
        return false unless go

        Builder.attach_ffi_function lib, go
        modul.class_eval FunctionBuilder.new(go).generate

        true
      end

      def build_namespaced_class classname
        info = gir.find_by_name @namespace, classname.to_s
        unless info
          raise NameError,
                "Class #{classname} not found in namespace #{@namespace}"
        end
        Builder.build_class info
      end

      private

      def modul
        unless defined? @module
          build_dependencies
          instantiate_module
          setup_lib_for_ffi unless lib_already_set_up
          setup_module unless already_set_up
        end
        @module
      end

      def build_dependencies
        deps = gir.dependencies @namespace
        deps.each {|dep|
          name, version = dep.split '-'
          Builder.build_module name, version
        }
      end

      def instantiate_module
        @module = get_or_define_module ::Object, @safe_namespace
      end

      def setup_module
        @module.extend ModuleBase
        @module.const_set :GIR_FFI_BUILDER, self
      end

      def already_set_up
        @module.const_defined? :GIR_FFI_BUILDER
      end

      def setup_lib_for_ffi
        lib.extend FFI::Library
        lib.ffi_lib_flags :global, :lazy
        if shared_library_specification
          lib.ffi_lib(*shared_library_specification.split(/,/))
        end
      end

      def shared_library_specification
        @shared_library_specification ||= gir.shared_library(@namespace)
      end

      def lib_already_set_up
        (class << lib; self; end).include? FFI::Library
      end

      def lib
        @lib ||= get_or_define_module modul, :Lib
      end

      def function_introspection_data function
        info = gir.find_by_name @namespace, function.to_s
        return unless info
        info.info_type == :function ? info : nil
      end

      def gir
        unless defined? @gir
          @gir = GObjectIntrospection::IRepository.default
          @gir.require @namespace, @version
        end
        @gir
      end
    end
  end
end
