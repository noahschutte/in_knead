joe = {
  fb_userID: 11111,
  email: "joe@email.com"
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
  creator: User.find(1),
  pizzas: 2,
  vendor: "Papa Johns",
  video: "1111",
  donor_id: 4,
  transcoded: true,
  status: "received"
}

request2 = {
  creator: User.find(2),
  pizzas: 1,
  vendor: "Dominos",
  video: "2222",
  transcoded: true
}

request3 = {
  creator: User.find(3),
  pizzas: 3,
  vendor: "Pizza Hut",
  video: "3333",
  donor_id: 1,
  transcoded: true,
  status: "received"
}


requests = [request1, request2, request3]

requests.each_with_index do |request, index|
  Request.create(creator: request[:creator], pizzas: request[:pizzas], vendor: request[:vendor], video: request[:video], donor_id: request[:donor_id], transcoded: request[:transcoded], status: request[:status])
end

thankYou1 = {
  creator: User.find(1),
  donor_id: 4,
  request_id: Request.find(1).id,
  pizzas: 2,
  vendor: "Papa Johns",
  video: "4444",
  donor_viewed: true,
  transcoded: true
}

thankYou3 = {
  creator: User.find(3),
  donor_id: 1,
  request_id: Request.find(3).id,
  pizzas: 3,
  vendor: "Pizza Hut",
  video: "6666",
  donor_viewed: false,
  transcoded: true
}

thankYous = [thankYou1, thankYou3]

thankYous.each_with_index do |thankYou, index|
  ThankYou.create(creator: thankYou[:creator], donor_id: thankYou[:donor_id], request_id: thankYou[:request_id], pizzas: thankYou[:pizzas], vendor: thankYou[:vendor], video: thankYou[:video], donor_viewed: thankYou[:donor_viewed], transcoded: thankYou[:transcoded])
end
