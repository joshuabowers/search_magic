Fabricator(:video) do
  title { Fabricate.sequence(:video_title) {|i| "video-title-#{i}"} }
  metadata {
    {
      "resolution" => %w[480i 480p 720p 1080p 1080i 1080p].sample,
      "duration" => 180 * rand
    }
  }
end