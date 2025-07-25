class HomeController < ApplicationController
  def index
    @user_names = [
      "Bret", "Antonette", "Samantha", "Karianne", "Kamren", "Leopoldo_Corkery",
      "Elwyn.Skiles", "Maxime_Nienow", "Delphine", "Moriah.Stanton"
    ]
  end
end
