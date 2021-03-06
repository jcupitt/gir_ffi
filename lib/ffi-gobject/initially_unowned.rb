GObject.load_class :InitiallyUnowned

module GObject
  # Overrides for GInitiallyUnowned, GObject's base class for objects that
  # start with a floating reference.
  class InitiallyUnowned
    # Wrapping method used in constructors. For InitiallyUnowned and
    # descendants, this needs to sink the object's floating reference.
    def self.constructor_wrap ptr
      super.tap { |obj| ::GObject::Lib.g_object_ref_sink obj }
    end
  end
end
