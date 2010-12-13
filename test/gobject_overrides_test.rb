require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi'

class GObjectOverridesTest < Test::Unit::TestCase
  context "The GObject module with overridden functions" do
    setup do
      GirFFI.setup :GObject
      GirFFI.setup :Everything
      GirFFI.setup :Gio
    end

    context "the wrap_in_g_value function" do
      should "wrap a boolean false" do
	gv = GObject.wrap_in_g_value false
	assert_instance_of GObject::Value, gv
	assert_equal false, gv.get_boolean
      end

      should "wrap a boolean true" do
	gv = GObject.wrap_in_g_value true
	assert_instance_of GObject::Value, gv
	assert_equal true, gv.get_boolean
      end
    end

    context "the unwrap_g_value function" do
      should "unwrap a boolean false" do
	gv = GObject.wrap_in_g_value false
	result = GObject.unwrap_g_value gv
	assert_equal false, result
      end

      should "unwrap a boolean true" do
	gv = GObject.wrap_in_g_value true
	result = GObject.unwrap_g_value gv
	assert_equal true, result
      end
    end

    context "the signal_emit function" do
      should "emit a signal" do
	a = 1
	o = Everything::TestSubObj.new
	GObject.signal_connect_data o, "test", Proc.new { a = 2 }, nil, nil, 0
	GObject.signal_emit o, "test"
	assert_equal 2, a
      end

      should "handle return values" do
	s = Gio::SocketService.new

	argtypes = [:pointer, :pointer, :pointer, :pointer]
	callback = FFI::Function.new(:bool, argtypes) { |a,b,c,d| true }
	GObject.signal_connect_data s, "incoming", callback, nil, nil, 0
	rv = GObject.signal_emit s, "incoming"
	assert_equal true, rv.get_boolean
      end
    end

    context "the signal_connect function" do
      should "install a signal handler" do
	a = 1
	o = Everything::TestSubObj.new
	GObject.signal_connect(o, "test") { a = 2 }
	GObject.signal_emit o, "test"
	assert_equal 2, a
      end

      should "pass user data to handler" do
	a = 1
	o = Everything::TestSubObj.new
	GObject.signal_connect(o, "test", 2) { |i, d| a = d }
	GObject.signal_emit o, "test"
	assert_equal 2, a
      end

      should "pass object to handler" do
	o = Everything::TestSubObj.new
	o2 = nil
	GObject.signal_connect(o, "test") { |i, d| o2 = i }
	GObject.signal_emit o, "test"
	assert_instance_of Everything::TestSubObj, o2
	assert_equal o.to_ptr, o2.to_ptr
      end

      should "not allow connecting an invalid signal" do
	o = Everything::TestSubObj.new
	assert_raises RuntimeError do
	  GObject.signal_connect(o, "not-really-a-signal") {}
	end
      end

      should "handle return values" do
	s = Gio::SocketService.new
	GObject.signal_connect(s, "incoming") { true }
	rv = GObject.signal_emit s, "incoming"
	assert_equal true, rv.get_boolean
      end

      should "handle extra signal arguments" do
	a = 1
	o = Everything::TestSubObj.new
	GObject.signal_connect(o, "test-with-static-scope-arg", 2) { |i, object, d|
	  a = d
	}
	GObject.signal_emit o, "test-with-static-scope-arg"
	assert_equal 2, a
      end

    end

    context "The GObject overrides Helper module" do
      context "#wrap_signal_arguments" do
	context "the result of wrapping test-with-static-scope-arg" do
	  setup do
	    o = Everything::TestSubObj.new
	    b = Everything::TestSimpleBoxedA.new

	    @gva = GirFFI::Overrides::GObject::Helper.wrap_signal_arguments "test-with-static-scope-arg", o, b
	  end

	  should "be a GObject::ValueArray" do
	    assert_instance_of GObject::ValueArray, @gva
	  end

	  should "contain two values" do
	    assert_equal 2, @gva[:n_values]
	  end

	  should "have a first value with GType for TestSubObj" do
	    assert_equal Everything::TestSubObj.get_gtype, (@gva.get_nth 0)[:g_type]
	  end

	  should "have a second value with GType for TestSimpleBoxedA" do
	    assert_equal Everything::TestSimpleBoxedA.get_gtype, (@gva.get_nth 1)[:g_type]
	  end
	end
      end
    end
  end
end


