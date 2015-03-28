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
    end

    def islogined(userid)
        return !cookies[:userid].blank?
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

    def login_page
    end

    def logined_page
    end

    def cleardata_page
        cleardata
        render text: ""
    end
end
