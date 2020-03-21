# coding: utf-8

User.create!(name: "Sample User",
             email: "sample_0@email.com",
             affiliation: "affiliation",
             password: "password",
             password_confirmation: "password",
             # db/migrate/[timestamp]_add_admin_to_users.rbにadminをデフォルトでfalseにする。
             admin: true) # 管理者権限を与える。

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  affiliation = "affiliation"
  password = "password"
  User.create!(name: name,
               email: email,
               affiliation: affiliation,
               password: password,
               password_confirmation: password)
end