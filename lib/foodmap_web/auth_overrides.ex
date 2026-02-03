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
        "w-full max-w-md bg-white/20 backdrop-blur-xl p-8 md:p-10 rounded-3xl border border-white/30 shadow-2xl"

    set :label_class, "text-white text-lg font-bold tracking-wide ml-1"

    # 2. Input: Large, rounded, and semi-transparent "Glass" style
    # 'p-4' and 'text-xl' make it feel premium and easy to use
    set :input_class, """
      w-full p-4 text-xl rounded-2xl border-2 border-white/20 
      bg-white/10 text-white placeholder:text-white/40
      focus:bg-white/20 focus:border-white/50 focus:ring-0 
      transition-all duration-200 outline-none
    """

    # 3. Submit Button: High contrast (Blue text on White background)
    set :submit_class, """
      w-full py-5 mt-4 bg-white text-blue-700 text-2xl font-black 
      rounded-2xl shadow-xl hover:scale-[1.02] active:scale-95 
      transition-all duration-200 cursor-pointer
    """
  end

  # 2. Wrap the form in a high-contrast card
  override AshAuthentication.Phoenix.Components.SignIn do
    # White background with blur and rounded corners makes the form "pop"
    # set :root_class,
    #      "w-full max-w-md bg-white p-8 md:p-10 rounded-3xl shadow-2xl flex flex-col gap-4 bg-gradient-to-br from-blue-600 via-teal-500 to-green-500"

    # "grid h-screen place-items-center bg-gradient-to-br from-blue-600 via-teal-500 to-green-500"

    # Bigger fonts and better spacing
    set :label_class, "text-gray-800 font-semibold text-lg mb-2 block"

    set :input_class,
        "w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-gray-900"

    # Fix the button
    set :submit_class,
        "w-full mt-6 py-4 bg-blue-600 hover:bg-blue-700 text-white font-bold text-xl rounded-xl transition-all shadow-lg active:scale-95"

    # Better contrast for footer links
    set :footer_class,
        "mt-6 flex justify-between text-sm font-medium text-gray-600 hover:text-blue-700"
  end
end
