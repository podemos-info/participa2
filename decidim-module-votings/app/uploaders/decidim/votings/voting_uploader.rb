# frozen_string_literal: true

module Decidim
  module Votings
    # This class deals with uploading avatars to a User.
    class VotingUploader < Decidim::ImageUploader
      include CarrierWave::MiniMagick

      process :validate_dimensions

      version :big do
        process resize_and_pad: [500, 500]
      end

      version :thumb do
        process resize_and_pad: [100, 100]
      end

      version :icon do
        process resize_and_pad: [40, 40]
      end
    end
  end
end
