class SwppController < ApplicationController
    def login(userid, userpass)
        member = Member.find_by(userid: userid, userpass: userpass)
        if member.blank?
            return -4
        else
            member.count += 1
            member.save
            # make cookie for login
            cookies[:userid] = userid
            return member.count
        end
    end

    def signup(userid, userpass)
        # check params first
        if userid.nil? || userid.length < 5 || userid.length > 20
            # inproper userid length
            return -1
        end
        if userpass.nil? || userpass.length < 8 || userpass.length > 20
            # improper userpass length
            return -2
        end


        begin
            member = Member.create(userid: userid, userpass: userpass, count: 0)
        rescue ActiveRecord::RecordNotUnique => e
            # same userid already exists
            return -3
        end

        if !member.valid?
            # this shouldn't be happened (cannot create member)
            return -3
        else
            # successfully sign_uped
            # now call login
            return login(userid, userpass)
        end
    end

    def logout
        # just delete cookie
        cookies.delete :userid
        print "logout"
    end

    def islogined
        return !cookies[:userid].blank?
    end

    def getlogincount(userid)
        member = Member.find_by(userid: userid)
        if member.blank?
            return -1
        else
            return member.count
        end
    end

    def cleardata
        Member.delete_all
    end

########################################
# JSON part start
########################################

    def login_json
        userid = params[:username]
        userpass = params[:password]
        ret = login(userid, userpass)
        if (ret >= 0)
            render :json => {:user_name => userid, :login_count => ret}
        else
            render :json => {:error_code => ret}
        end
    end

    def signup_json
        userid = params[:username]
        userpass = params[:password]
        ret = signup(userid, userpass)
        if (ret >= 0)
            render :json => {:user_name => userid, :login_count => ret}
        else
            render :json => {:error_code => ret}
        end
    end

########################################
# Page part start
########################################

    def main_page
        if islogined
            # check if user selected logout
            if (params[:status] == "logout")
                logout
                login_page
            else
                logined_page
            end
        else
            login_page
        end
    end

    def login_page
        # init
        @errormsg = ""

        if params.has_key?(:username) && params.has_key?(:password)
            userid = params[:username]
            userpass = params[:password]
            status = params[:status]
            if (status == "login")
                ret = login(userid, userpass)
            elsif (status == "adduser")
                ret = signup(userid, userpass)
            end
            if (ret > 0)
                logined_page
                return
            elsif (ret < 0)
                if ret == -1
                    @errormsg = "The user name should be 5~20 characters long. Please try again."
                elsif ret == -2
                    @errormsg = "The password should be 8~20 characters long. Please try again."
                elsif ret == -3
                    @errormsg = "This user name already exists. Please try again."
                elsif ret == -4
                    @errormsg = "Invalid username and password combination. Please try again."
                end
            end
        end
        render template: "login_page.erb"
    end

    def logined_page
        @userid = cookies[:userid]
        @count = getlogincount(@userid)
        render template: "logined_page.erb"
    end

    def cleardata_page
        cleardata
        render :text => ""
    end
end
