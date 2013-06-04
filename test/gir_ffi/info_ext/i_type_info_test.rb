require 'gir_ffi_test_helper'

describe GirFFI::InfoExt::ITypeInfo do
  let(:testclass) { Class.new do
    include GirFFI::InfoExt::ITypeInfo
  end }
  let(:type_info) { testclass.new }
  let(:elmtype_info) { testclass.new }
  let(:keytype_info) { testclass.new }
  let(:valtype_info) { testclass.new }

  describe "#layout_specification_type" do
    it "returns an array with elements subtype and size for type :array" do
      mock(type_info).pointer? { false }
      stub(type_info).tag { :array }
      mock(type_info).array_fixed_size { 2 }

      mock(elmtype_info).layout_specification_type { :foo }
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.layout_specification_type
      assert_equal [:foo, 2], result
    end
  end

  describe "#element_type" do
    it "returns the element type for lists" do
      mock(elmtype_info).tag { :foo }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elmtype_info }

      result = type_info.element_type
      result.must_equal :foo
    end

    it "returns the key and value types for ghashes" do
      mock(keytype_info).tag { :foo }
      mock(valtype_info).tag { :bar }

      mock(type_info).tag {:ghash}
      mock(type_info).param_type(0) { keytype_info }
      mock(type_info).param_type(1) { valtype_info }

      result = type_info.element_type
      result.must_equal [:foo, :bar]
    end

    it "returns nil for other types" do
      mock(type_info).tag {:foo}

      result = type_info.element_type
      result.must_be_nil
    end

    it "returns :gpointer if the element type is a pointer with tag :void" do
      stub(elm_type = Object.new).tag { :void }
      stub(elm_type).pointer? { true }

      mock(type_info).tag {:glist}
      mock(type_info).param_type(0) { elm_type }

      assert_equal :gpointer, type_info.element_type
    end
  end

  describe "#flattened_tag" do
    describe "for a simple type" do
      it "returns the type tag" do
        stub(type_info).tag { :uint32 }

        type_info.flattened_tag.must_equal :uint32
      end
    end

    context "for a zero-terminated array" do
      before do
        stub(type_info).tag { :array }
        stub(type_info).param_type(0) { elmtype_info }
        stub(type_info).zero_terminated? { true }
      end

      context "of utf8" do
        it "returns :strv" do
          stub(elmtype_info).tag { :utf8 }

          type_info.flattened_tag.must_equal :strv
        end
      end

      context "of filename" do
        it "returns :strv" do
          stub(elmtype_info).tag { :filename }

          type_info.flattened_tag.must_equal :strv
        end
      end

      context "of another type" do
        it "returns :zero_terminated" do
          stub(elmtype_info).tag { :foo }

          type_info.flattened_tag.must_equal :zero_terminated
        end
      end
    end

    describe "for a fixed length c-like array" do
      it "returns :c" do
        mock(type_info).tag { :array }
        mock(type_info).zero_terminated? { false }
        mock(type_info).array_type { :c }

        type_info.flattened_tag.must_equal :c
      end
    end

  end

  describe "#subtype_tag_or_class_name" do
    describe "for a simple type" do
      it "returns the string ':void'" do
        mock(subtype = Object.new).tag { :void }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal ":void", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of simple type :foo" do
      it "returns the string ':foo'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal ":foo", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of :utf8" do
      it "returns the string ':utf8'" do
        mock(subtype = Object.new).tag { :utf8 }
        mock(subtype).pointer? { true }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal ":utf8", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of an interface class" do
      it "returns the interface's full class name" do
        mock(subtype = Object.new).tag { :interface }
        mock(subtype).interface_type_name { "-full-type-name-" }
        mock(subtype).pointer? { false }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal "-full-type-name-", info.subtype_tag_or_class_name
      end
    end

    describe "for an array of pointer to simple type :foo" do
      it "returns the string '[:pointer, :foo]'" do
        mock(subtype = Object.new).tag { :foo }
        mock(subtype).pointer? { true }

        mock(info = testclass.new).param_type(0) { subtype }

        assert_equal "[:pointer, :foo]", info.subtype_tag_or_class_name
      end
    end
  end
end
