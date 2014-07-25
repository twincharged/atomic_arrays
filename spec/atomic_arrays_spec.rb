require 'spec_helper'

describe AtomicArrays do

  before(:all) do
    @user1 = User.find(1)
    @user2 = User.find(2)
    @user3 = User.find(3)
    @user4 = User.find(4)
    @user5 = User.find(5)
    @user6 = User.find(6)
    @comment1 = Comment.find(1)
    @comment2 = Comment.find(2)
    @comment3 = Comment.find(3)
    @comment4 = Comment.find(4)
    @comment5 = Comment.find(5)
    @comment6 = Comment.find(6)
  end

  describe "atomic appending" do

    it "should append string to user" do
      hob = "NewHobby"
      user = @user1.atomic_append(:hobbies, hob)
      expect(user.hobbies).to include hob
      expect(User.find(1).hobbies).to include hob
    end

    it "should append string to comment" do
      tag = "NewTag"
      comm = @comment1.atomic_append(:tags, tag)
      expect(comm.tags).to include tag
      expect(Comment.find(1).tags).to include tag
    end

    it "should append integer to user" do
      id = 9
      user = @user2.atomic_append(:comment_ids, id)
      expect(user.comment_ids).to include id
      expect(User.find(2).comment_ids).to include id
    end

    it "should append string to comment" do
      id = 8
      comm = @comment2.atomic_append(:liker_ids, id)
      expect(comm.liker_ids).to include id
      expect(Comment.find(2).liker_ids).to include id
    end
  end


  describe "atomic removing" do

    it "should remove string to user" do
      hob = "NewHobby"
      user = @user1.atomic_remove(:hobbies, hob)
      expect(user.hobbies).to_not include hob
      expect(User.find(1).hobbies).to_not include hob
    end

    it "should remove string to comment" do
      tag = "NewTag"
      comm = @comment1.atomic_remove(:tags, tag)
      expect(comm.tags).to_not include tag
      expect(Comment.find(1).tags).to_not include tag
    end

    it "should remove integer to user" do
      id = 9
      user = @user2.atomic_remove(:comment_ids, id)
      expect(user.comment_ids).to_not include id
      expect(User.find(2).comment_ids).to_not include id
    end

    it "should remove string to comment" do
      id = 8
      comm = @comment2.atomic_remove(:liker_ids, id)
      expect(comm.liker_ids).to_not include id
      expect(Comment.find(2).liker_ids).to_not include id
    end
  end



  describe "atomic concatenating" do

    it "should cat strings to user" do
      hobs = ["NewHobby", "Anothernewhobby", "Hobby3"]
      user = @user3.atomic_cat(:hobbies, hobs)
      expect(user.hobbies).to include *hobs
      expect(User.find(3).hobbies).to include *hobs
    end

    it "should cat strings to comment" do
      tags = ["NewTag", "#sick", "#iheartfood"]
      comm = @comment3.atomic_cat(:tags, tags)
      expect(comm.tags).to include *tags
      expect(Comment.find(3).tags).to include *tags
    end

    it "should cat integers to user" do
      ids = [9,234,12,7]
      user = @user3.atomic_cat(:comment_ids, ids)
      expect(user.comment_ids).to include *ids
      expect(User.find(3).comment_ids).to include *ids
    end

    it "should cat strings to comment" do
      ids = [8,98,43,22]
      comm = @comment3.atomic_cat(:liker_ids, ids)
      expect(comm.liker_ids).to include *ids
      expect(Comment.find(3).liker_ids).to include *ids
    end
  end



  describe "atomic relating" do

    it "should relate comment id array" do
      comm = [@comment1,@comment2,@comment4]
      @user3.update({comment_ids: comm.map(&:id)})
      comments = @user3.atomic_relate(:comment_ids, Comment)
      expect(comments).to include *comm
    end

    it "should relate user id array" do
      us = [@user1,@user2,@user4]
      @comment5.update({liker_ids: us.map(&:id)})
      users = @comment5.atomic_relate(:liker_ids, User)
      expect(users).to include *us
    end
  end

end