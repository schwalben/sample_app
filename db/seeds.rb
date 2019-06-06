User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# リレーションシップ
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

microposts = Micropost.all
microposts.each_with_index { |micropost, i| 
  if (i % 2 == 1)
    Good.create(micropost_id: micropost.id, created_by_id: user.id)
  end
}

second_user = users[1]
microposts.each_with_index { |micropost, i| 
  if (i % 2 == 0)
    Good.create(micropost_id: micropost.id, created_by_id: second_user.id)
  end
}

third_user = users[2]
microposts.each_with_index { |micropost, i| 
  if (i % 2 == 1)
    Good.create(micropost_id: micropost.id, created_by_id: third_user.id)
  end
}

microposts.each_with_index { |micropost, i| 
    count = Good.find_by(micropost_id: micropost.id)
    micropost.update(goods_count: count)
}
