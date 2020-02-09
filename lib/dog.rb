class Dog < ActiveRecord::Base
  belongs_to :farmer

    def flavor_text
      [
        "#{self.name} is quietly snoring on your bed...",
        "Oh no! #{self.name} found their way into the \nfridge and ate all of the string cheese!",
        "#{self.name} seems to have constructed their \nown fort, made entirely of your boots.",
        "#{self.name} excitedly jumps at you, barking. \nWelcome home!",
        "#{self.name} is watching the Galactic News Network \non TV. Space Pirates appear to wreaking \nhavoc again...",
        "Gasp! #{self.name} is missing! \n... Oh wait, they're right there on the sofa.",
        "#{self.name} is playing with their favorite toy.\n It squeaks as they gnaw on it.",
        "#{self.name} is watching TV. There is a \nparakeet on a branch. #{self.name} really \nwants to touch it!",
        "#{self.name} is starting to look a bit dirty. \nTime for a bath!"
      ]
      .sample
    end

    def get_petted
      if self.petted == 1
        "You pet #{self.name} more. Who's a good dog?"
      else
        self.update(petted: 1)
        "You pet #{self.name}! They seem to like it."
      end
    end
end
