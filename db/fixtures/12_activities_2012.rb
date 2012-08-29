# encoding: UTF-8

### Sep 5th

Activity.seed do |activity|
  activity.id = 1
  activity.room_id = 1
  activity.start_at = "2012-09-05 09:00:00"
  activity.end_at = "2012-09-05 09:10:00"
  activity.detail_id = 1
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 2
  activity.room_id = 1
  activity.start_at = "2012-09-05 09:10:00"
  activity.end_at = "2012-09-05 10:30:00"
  activity.detail_id = 1
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 3
  activity.room_id = 1
  activity.start_at = "2012-09-05 10:30:00"
  activity.end_at = "2012-09-05 11:00:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 4
  activity.room_id = 1
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 12:00:00"
  activity.detail_id = 4
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 5
  activity.room_id = 2
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 12:00:00"
  activity.detail_id = 406
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 6
  activity.room_id = 3
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 12:00:00"
  activity.detail_id = 559
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 7
  activity.room_id = 4
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 443
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 8
  activity.room_id = 5
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 604
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 9
  activity.room_id = 1
  activity.start_at = "2012-09-05 12:00:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 516
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 10
  activity.room_id = 2
  activity.start_at = "2012-09-05 12:00:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 350
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 11
  activity.room_id = 3
  activity.start_at = "2012-09-05 12:00:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 1
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 12
  activity.room_id = 1
  activity.start_at = "2012-09-05 13:00:00"
  activity.end_at = "2012-09-05 14:30:00"
  activity.detail_id = 3
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 13
  activity.room_id = 1
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 15:30:00"
  activity.detail_id = 5
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 14
  activity.room_id = 2
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 15:30:00"
  activity.detail_id = 625
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 15
  activity.room_id = 3
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 15:30:00"
  activity.detail_id = 619
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 16
  activity.room_id = 4
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 15:30:00"
  activity.detail_id = 457
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 17
  activity.room_id = 5
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 16:30:00"
  activity.detail_id = 394
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 18
  activity.room_id = 1
  activity.start_at = "2012-09-05 15:30:00"
  activity.end_at = "2012-09-05 16:30:00"
  activity.detail_id = 385
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 19
  activity.room_id = 2
  activity.start_at = "2012-09-05 15:30:00"
  activity.end_at = "2012-09-05 16:30:00"
  activity.detail_id = 454
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 20
  activity.room_id = 3
  activity.start_at = "2012-09-05 15:30:00"
  activity.end_at = "2012-09-05 16:30:00"
  activity.detail_id = 602
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 21
  activity.room_id = 4
  activity.start_at = "2012-09-05 15:30:00"
  activity.end_at = "2012-09-05 16:30:00"
    activity.detail_id = 392
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 22
  activity.room_id = 1
  activity.start_at = "2012-09-05 16:30:00"
  activity.end_at = "2012-09-05 17:00:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 23
  activity.room_id = 1
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 18:00:00"
  activity.detail_id = 590
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 24
  activity.room_id = 2
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 18:00:00"
  activity.detail_id = 546
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 25
  activity.room_id = 3
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 18:00:00"
  activity.detail_id = 363
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 26
  activity.room_id = 4
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 18:00:00"
  activity.detail_id = 498
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 27
  activity.room_id = 5
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = 533
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 28
  activity.room_id = 1
  activity.start_at = "2012-09-05 18:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = 581
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 29
  activity.room_id = 2
  activity.start_at = "2012-09-05 18:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = 409
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 30
  activity.room_id = 3
  activity.start_at = "2012-09-05 18:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = 441
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 31
  activity.room_id = 4
  activity.start_at = "2012-09-05 18:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = 450
  activity.detail_type = 'Session'
end

### Sep 6th

Activity.seed do |activity|
  activity.id = 32
  activity.room_id = 1
  activity.start_at = "2012-09-06 09:00:00"
  activity.end_at = "2012-09-06 10:00:00"
  activity.detail_id = 2
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 33
  activity.room_id = 1
  activity.start_at = "2012-09-06 10:00:00"
  activity.end_at = "2012-09-06 10:30:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 34
  activity.room_id = 1
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 11:30:00"
  activity.detail_id = 6
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 35
  activity.room_id = 2
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 11:30:00"
  activity.detail_id = 460
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 36
  activity.room_id = 3
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 11:30:00"
  activity.detail_id = 493
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 37
  activity.room_id = 4
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 11:30:00"
  activity.detail_id = 352
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 38
  activity.room_id = 5
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 12:30:00"
  activity.detail_id = 476
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 39
  activity.room_id = 1
  activity.start_at = "2012-09-06 11:30:00"
  activity.end_at = "2012-09-06 12:30:00"
  activity.detail_id = 565
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 40
  activity.room_id = 2
  activity.start_at = "2012-09-06 11:30:00"
  activity.end_at = "2012-09-06 12:30:00"
  activity.detail_id = 370
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 41
  activity.room_id = 3
  activity.start_at = "2012-09-06 11:30:00"
  activity.end_at = "2012-09-06 12:30:00"
  activity.detail_id = 447
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 42
  activity.room_id = 4
  activity.start_at = "2012-09-06 11:30:00"
  activity.end_at = "2012-09-06 12:30:00"
  activity.detail_id = 615
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 43
  activity.room_id = 1
  activity.start_at = "2012-09-06 12:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 2
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 44
  activity.room_id = 2
  activity.start_at = "2012-09-06 12:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 3
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 45
  activity.room_id = 3
  activity.start_at = "2012-09-06 12:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 4
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 46
  activity.room_id = 4
  activity.start_at = "2012-09-06 12:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 5
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 47
  activity.room_id = 5
  activity.start_at = "2012-09-06 12:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 6
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 48
  activity.room_id = 1
  activity.start_at = "2012-09-06 13:00:00"
  activity.end_at = "2012-09-06 14:30:00"
  activity.detail_id = 3
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 49
  activity.room_id = 1
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 15:30:00"
  activity.detail_id = 8
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 50
  activity.room_id = 2
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 15:30:00"
  activity.detail_id = 560
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 51
  activity.room_id = 3
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 15:30:00"
  activity.detail_id = 429
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 52
  activity.room_id = 4
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 15:30:00"
  activity.detail_id = 517
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 53
  activity.room_id = 5
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 484
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 54
  activity.room_id = 1
  activity.start_at = "2012-09-06 15:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 514
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 55
  activity.room_id = 2
  activity.start_at = "2012-09-06 15:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 612
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 56
  activity.room_id = 3
  activity.start_at = "2012-09-06 15:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 7
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 57
  activity.room_id = 4
  activity.start_at = "2012-09-06 15:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 451
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 58
  activity.room_id = 1
  activity.start_at = "2012-09-06 16:30:00"
  activity.end_at = "2012-09-06 17:00:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 59
  activity.room_id = 1
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 18:00:00"
  activity.detail_id = 593
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 60
  activity.room_id = 2
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 18:00:00"
  activity.detail_id = 513
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 61
  activity.room_id = 3
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 18:00:00"
  activity.detail_id = 430
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 62
  activity.room_id = 4
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 18:00:00"
  activity.detail_id = 485
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 63
  activity.room_id = 5
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = 405
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 64
  activity.room_id = 1
  activity.start_at = "2012-09-06 18:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = 7
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 65
  activity.room_id = 2
  activity.start_at = "2012-09-06 18:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = 471
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 66
  activity.room_id = 3
  activity.start_at = "2012-09-06 18:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = 562
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 67
  activity.room_id = 4
  activity.start_at = "2012-09-06 18:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = 522
  activity.detail_type = 'Session'
end

### Sep 7th

Activity.seed do |activity|
  activity.id = 68
  activity.room_id = 1
  activity.start_at = "2012-09-07 09:00:00"
  activity.end_at = "2012-09-07 10:00:00"
  activity.detail_id = 3
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 69
  activity.room_id = 1
  activity.start_at = "2012-09-07 10:00:00"
  activity.end_at = "2012-09-07 10:30:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 70
  activity.room_id = 1
  activity.start_at = "2012-09-07 10:30:00"
  activity.end_at = "2012-09-07 11:30:00"
  activity.detail_id = 359
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 71
  activity.room_id = 2
  activity.start_at = "2012-09-07 10:30:00"
  activity.end_at = "2012-09-07 11:30:00"
  activity.detail_id = 9
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 72
  activity.room_id = 3
  activity.start_at = "2012-09-07 10:30:00"
  activity.end_at = "2012-09-07 11:30:00"
  activity.detail_id = 578
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 73
  activity.room_id = 4
  activity.start_at = "2012-09-07 10:30:00"
  activity.end_at = "2012-09-07 11:30:00"
  activity.detail_id = 495
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 74
  activity.room_id = 5
  activity.start_at = "2012-09-07 10:30:00"
  activity.end_at = "2012-09-07 12:30:00"
  activity.detail_id = 577
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 75
  activity.room_id = 1
  activity.start_at = "2012-09-07 11:30:00"
  activity.end_at = "2012-09-07 12:30:00"
  activity.detail_id = 595
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 76
  activity.room_id = 2
  activity.start_at = "2012-09-07 11:30:00"
  activity.end_at = "2012-09-07 12:30:00"
  activity.detail_id = 418
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 77
  activity.room_id = 3
  activity.start_at = "2012-09-07 11:30:00"
  activity.end_at = "2012-09-07 12:30:00"
  activity.detail_id = 587
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 78
  activity.room_id = 4
  activity.start_at = "2012-09-07 11:30:00"
  activity.end_at = "2012-09-07 12:30:00"
  activity.detail_id = 561
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 79
  activity.room_id = 1
  activity.start_at = "2012-09-07 12:30:00"
  activity.end_at = "2012-09-07 14:00:00"
  activity.detail_id = 3
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 80
  activity.room_id = 1
  activity.start_at = "2012-09-07 14:00:00"
  activity.end_at = "2012-09-07 15:00:00"
  activity.detail_id = 607
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 81
  activity.room_id = 2
  activity.start_at = "2012-09-07 14:00:00"
  activity.end_at = "2012-09-07 15:30:00"
  activity.detail_id = 542
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 82
  activity.room_id = 3
  activity.start_at = "2012-09-07 14:00:00"
  activity.end_at = "2012-09-07 15:00:00"
  activity.detail_id = 551
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 83
  activity.room_id = 4
  activity.start_at = "2012-09-07 14:00:00"
  activity.end_at = "2012-09-07 15:00:00"
  activity.detail_id = 545
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 84
  activity.room_id = 5
  activity.start_at = "2012-09-07 14:00:00"
  activity.end_at = "2012-09-07 15:00:00"
  activity.detail_id = 8
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 85
  activity.room_id = 1
  activity.start_at = "2012-09-07 15:00:00"
  activity.end_at = "2012-09-07 16:00:00"
  activity.detail_id = 446
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 86
  activity.room_id = 2
  activity.start_at = "2012-09-07 15:30:00"
  activity.end_at = "2012-09-07 16:00:00"
  activity.detail_id = 505
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 87
  activity.room_id = 3
  activity.start_at = "2012-09-07 15:00:00"
  activity.end_at = "2012-09-07 16:00:00"
  activity.detail_id = 413
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 88
  activity.room_id = 4
  activity.start_at = "2012-09-07 15:00:00"
  activity.end_at = "2012-09-07 16:00:00"
  activity.detail_id = 407
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 89
  activity.room_id = 5
  activity.start_at = "2012-09-07 15:00:00"
  activity.end_at = "2012-09-07 16:00:00"
  activity.detail_id = 9
  activity.detail_type = 'LightningTalkGroup'
end

Activity.seed do |activity|
  activity.id = 90
  activity.room_id = 1
  activity.start_at = "2012-09-07 16:00:00"
  activity.end_at = "2012-09-07 16:30:00"
  activity.detail_id = 4
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 91
  activity.room_id = 1
  activity.start_at = "2012-09-07 16:30:00"
  activity.end_at = "2012-09-07 17:30:00"
  activity.detail_id = 481
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 92
  activity.room_id = 2
  activity.start_at = "2012-09-07 16:30:00"
  activity.end_at = "2012-09-07 17:30:00"
  activity.detail_id = 463
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 93
  activity.room_id = 3
  activity.start_at = "2012-09-07 16:30:00"
  activity.end_at = "2012-09-07 17:30:00"
  activity.detail_id = 401
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 94
  activity.room_id = 4
  activity.start_at = "2012-09-07 16:30:00"
  activity.end_at = "2012-09-07 17:30:00"
  activity.detail_id = 525
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 95
  activity.room_id = 5
  activity.start_at = "2012-09-07 16:30:00"
  activity.end_at = "2012-09-07 18:30:00"
  activity.detail_id = 573
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 96
  activity.room_id = 1
  activity.start_at = "2012-09-07 17:30:00"
  activity.end_at = "2012-09-07 18:30:00"
  activity.detail_id = nil # TODO: BLANK
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 97
  activity.room_id = 2
  activity.start_at = "2012-09-07 17:30:00"
  activity.end_at = "2012-09-07 18:30:00"
  activity.detail_id = nil # TODO: BLANK
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 98
  activity.room_id = 3
  activity.start_at = "2012-09-07 17:30:00"
  activity.end_at = "2012-09-07 18:30:00"
  activity.detail_id = 529
  activity.detail_type = 'Session'
end

Activity.seed do |activity|
  activity.id = 99
  activity.room_id = 4
  activity.start_at = "2012-09-07 17:30:00"
  activity.end_at = "2012-09-07 18:30:00"
  activity.detail_id = 12
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 100
  activity.room_id = 1
  activity.start_at = "2012-09-07 18:30:00"
  activity.end_at = "2012-09-07 19:00:00"
  activity.detail_id = 2
  activity.detail_type = 'AllHands'
end

### WBMA

Activity.seed do |activity|
  activity.id = 101
  activity.room_id = 6
  activity.start_at = "2012-09-05 11:00:00"
  activity.end_at = "2012-09-05 11:10:00"
  activity.detail_id = 13
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 102
  activity.room_id = 6
  activity.start_at = "2012-09-05 11:10:00"
  activity.end_at = "2012-09-05 12:00:00"
  activity.detail_id = 14
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 103
  activity.room_id = 6
  activity.start_at = "2012-09-05 12:00:00"
  activity.end_at = "2012-09-05 12:30:00"
  activity.detail_id = 15
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 104
  activity.room_id = 6
  activity.start_at = "2012-09-05 12:30:00"
  activity.end_at = "2012-09-05 13:00:00"
  activity.detail_id = 16
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 105
  activity.room_id = 6
  activity.start_at = "2012-09-05 14:30:00"
  activity.end_at = "2012-09-05 15:00:00"
  activity.detail_id = 17
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 106
  activity.room_id = 6
  activity.start_at = "2012-09-05 15:00:00"
  activity.end_at = "2012-09-05 15:30:00"
  activity.detail_id = 18
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 107
  activity.room_id = 6
  activity.start_at = "2012-09-05 15:30:00"
  activity.end_at = "2012-09-05 16:00:00"
  activity.detail_id = 19
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 108
  activity.room_id = 6
  activity.start_at = "2012-09-05 16:00:00"
  activity.end_at = "2012-09-05 16:30:00"
  activity.detail_id = 20
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 109
  activity.room_id = 6
  activity.start_at = "2012-09-05 16:30:00"
  activity.end_at = "2012-09-05 17:00:00"
  activity.detail_id = 21
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 110
  activity.room_id = 6
  activity.start_at = "2012-09-05 17:00:00"
  activity.end_at = "2012-09-05 17:30:00"
  activity.detail_id = 22
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 111
  activity.room_id = 6
  activity.start_at = "2012-09-05 17:30:00"
  activity.end_at = "2012-09-05 18:00:00"
  activity.detail_id = 23
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 112
  activity.room_id = 6
  activity.start_at = "2012-09-05 18:00:00"
  activity.end_at = "2012-09-05 19:00:00"
  activity.detail_id = nil
  activity.detail_type = 'Session'
end

### Executive Summit

Activity.seed do |activity|
  activity.id = 123
  activity.room_id = 7
  activity.start_at = "2012-09-06 10:30:00"
  activity.end_at = "2012-09-06 11:30:00"
  activity.detail_id = 24
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 124
  activity.room_id = 7
  activity.start_at = "2012-09-06 11:30:00"
  activity.end_at = "2012-09-06 13:00:00"
  activity.detail_id = 25
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 125
  activity.room_id = 7
  activity.start_at = "2012-09-06 14:30:00"
  activity.end_at = "2012-09-06 15:30:00"
  activity.detail_id = 26
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 126
  activity.room_id = 7
  activity.start_at = "2012-09-06 15:30:00"
  activity.end_at = "2012-09-06 16:30:00"
  activity.detail_id = 27
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 127
  activity.room_id = 7
  activity.start_at = "2012-09-06 17:00:00"
  activity.end_at = "2012-09-06 18:00:00"
  activity.detail_id = 28
  activity.detail_type = 'GuestSession'
end

Activity.seed do |activity|
  activity.id = 128
  activity.room_id = 7
  activity.start_at = "2012-09-06 18:00:00"
  activity.end_at = "2012-09-06 19:00:00"
  activity.detail_id = nil
  activity.detail_type = 'Session'
end

### Registration

Activity.seed do |activity|
  activity.id = 129
  activity.room_id = 1
  activity.start_at = "2012-09-05 08:00:00"
  activity.end_at = "2012-09-05 09:00:00"
  activity.detail_id = 5
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 130
  activity.room_id = 1
  activity.start_at = "2012-09-06 08:00:00"
  activity.end_at = "2012-09-06 09:00:00"
  activity.detail_id = 5
  activity.detail_type = 'AllHands'
end

Activity.seed do |activity|
  activity.id = 131
  activity.room_id = 1
  activity.start_at = "2012-09-07 08:00:00"
  activity.end_at = "2012-09-07 09:00:00"
  activity.detail_id = 5
  activity.detail_type = 'AllHands'
end
