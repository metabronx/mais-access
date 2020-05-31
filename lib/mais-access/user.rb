# frozen_string_literal: true

module MaisAccess
  # An abstract class used to store the currently authenticated MAIS user. An instance of
  # this class is initialized every time `authenticate_mais_user!` completes successfully.
  # The current MAIS user can be accessed anytime via the `mais_user` method.
  class User
    attr_reader :username, :full_name

    def initialize(*params)
      params = params[0]
      @username = params["username"]
      @full_name = params["full_name"]
    end
  end
end