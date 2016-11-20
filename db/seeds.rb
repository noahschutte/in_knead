joe = {
  fb_userID: 11111,
  email: "joe@email.com",
}

monica = {
  fb_userID: 22222,
  email: "monica@email.com"
}

bob = {
  fb_userID: 33333,
  email: "bob@email.com"
}

fred = {
  fb_userID: 44444,
  email: "fred@email.com"
}

sally = {
  fb_userID: 55555,
  email: "sally@email.com"
}

users = [joe, monica, bob, fred, sally]

users.each do |user|
  User.create(fb_userID: user[:fb_userID], signup_email: user[:email], current_email: user[:email])
end

request1 = {
  creator: joe,
  pizzas: 2,
  vendor: "Papa Johns",
  video: "1556_1881.mp4"
}

request2 = {
  creator: monica,
  pizzas: 2,
  vendor: "Dominos",
  video: "3862_2925.mp4",
  donor_id: 1
}

request3 = {
  creator: bob,
  pizzas: 3,
  vendor: "Pizza Hut",
  video: "4190_4633.mp4"
}

request4 = {
  creator: fred,
  pizzas: 1,
  vendor: "Dominos",
  video: "YOU WANT YOUR PIZZA ROLLZ (sky short).mp4"
}

requests = [request1, request2, request3, request4]

requests.each_with_index do |request, index|
  Request.create(creator: User.find(index+1), pizzas: request[:pizzas], vendor: request[:vendor], video: request[:video], donor_id: request[:donor_id])
end
