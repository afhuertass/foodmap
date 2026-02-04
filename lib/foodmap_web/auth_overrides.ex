defmodule FoodmapWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # The body contains any number of configurations you wish to override
  # Below are some examples

  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html
  override AshAuthentication.Phoenix.SignInLive do
    set :root_class,
        "fixed inset-0 grid place-items-center bg-gradient-to-br from-blue-600 via-teal-500 to-green-500 overflow-y-auto p-4"

    # Make the button look like a button, not a line
  end

  override AshAuthentication.Phoenix.Components.Banner do
    set :image_url, "/images/foodmap-svg.svg"
    set :dark_image_url, "/images/foodmap-svg.svg"

    set :root_class, "flex flex-col items-center justify-center mb-8 w-full"
    # Hiding the default "Register" text allows your logo to be the hero
    set :header_class, "hidden"
  end

  # override AshAuthentication.Phoenix.Components.SignIn do
  #   set :root_class,
  #       "relative bg-gradient-to-br from-blue-500 to-green-400 min-h-screen flex items-center justify-center px-4"
  # end
  #
  # 1. Target the LiveView container
  # override AshAuthentication.Phoenix.Components.Password.RegisterForm do
  #   # Added "p-4" so the box doesn't touch the screen edges on mobile
  #   set :root_class,
  #       "grid h-screen place-items-center bg-gradient-to-br from-blue-600 via-teal-500 to-black-400 p-10"
  # end

  override AshAuthentication.Phoenix.Components.Password.RegisterForm do
    # This creates the white "box" around your inputs
    set :root_class,
        "w-full max-w-2xl bg-white/20 backdrop-blur-xl p-8 md:p-10 rounded-3xl border border-white/30 shadow-2xl"

    # 2. Input: Large, rounded, and semi-transparent "Glass" style
    # 'p-4' and 'text-xl' make it feel premium and easy to use
    set :input_class, """
      w-full p-4 text-xl rounded-2xl border-2 border-white/30 
      bg-white/10 text-white placeholder:text-white/50
      focus:!bg-white/20 focus:border-white/60 focus:ring-0 
      transition-all duration-200 outline-none mb-2
    """

    set :footer_class, """
      mt-8 flex justify-between gap-4 text-sm font-bold 
      text-white/90 underline decoration-white/30 hover:text-white
    """
  end

  override AshAuthentication.Phoenix.Components.Password.SignInForm do
    set :root_class,
        "w-full max-w-2xl bg-white/10 backdrop-blur-xl p-8 md:p-10 rounded-3xl border border-white/20 shadow-2xl"

    set :label_class,
        "text-white text-2xl font-black tracking-widest mb-3 block drop-shadow-md uppercase"

    set :input_class, """
      w-full p-4 text-xl rounded-2xl border-2 border-white/30 
      bg-white/10 text-white placeholder:text-white/50
      focus:!bg-white/20 focus:border-white/60 focus:ring-0 
      transition-all duration-200 outline-none mb-2
    """

    set :footer_class, """
      mt-8 flex justify-between gap-4 text-sm font-bold 
      text-white/90 underline decoration-white/30 hover:text-white
    """

    set :submit_class,
        "w-full py-5 mt-4 bg-white text-black-700 text-2xl font-black rounded-2xl shadow-xl hover:scale-[1.02] active:scale-95 transition-all cursor-pointer"
  end

  override AshAuthentication.Phoenix.Components.Password.Input do
    set :label_class,
        "text-white text-2l font-black tracking-widest mb-3 block drop-shadow-md uppercase"

    set :input_class, """
      w-full p-4 text-xl font-bold rounded-2xl border-2 border-white/30 
      bg-gray-200/90 text-black placeholder:text-gray-500
      focus:bg-gray-100 focus:border-white/80 focus:ring-0 
      transition-all duration-200 outline-none mb-2
    """
  end
end
