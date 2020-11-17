#!/bin/bash
for i in mediawiki redmine nginx mysql httpd certbot/dns-digitalocean certbot/certbot; do
  #result=$(sudo docker images | grep $i 2>&1 /dev/null);
  result=$(sudo docker images | grep $i)
  #echo "DEBUG: result is: $result"
  :
done

a_yml=./docker-compose.yml
# this zeros a_yml
:> $a_yml

# parameterize images as array
#image_array=$(sudo docker images | sed -n '2,$p' | grep -v -i "none" | awk '{print $1}' | sed s'/\///' | while read adock; do echo $adock && if [[ $adock = *sql* ]]; then echo $adock-data && echo $adock-mediawiki && echo $adock-redmine && echo $adock-linuxselftest; else :; fi; done)
image_array=$(sudo docker images | sed -n '2,$p' | grep -v -i "none" | awk '{print $1}' | sed s'/\///' | while read adock; do echo $adock;  done)
#image_dir_array=$(for i in $image_array; do echo $
#sudo docker images | sed -n '2,$p' | awk '{print $1}' | sed s'/\///' | while read adock; do echo $adock; done
i=0
mkdir ${image_array[*]} 2> /dev/null
for image in $image_array; do
  if [ -f ./$image/Dockerfile-$image ]; then
    :
    #echo "Found Dockerfile-$image for $image"
  else
    echo "Creating Dockerfile-$image for $image"
    :> ./$image/Dockerfile-$image
  fi
  #effortlevel=$(wc ./$image/Dockerfile-$image -c)
  #echo "effortlevel is: $effortlevel"
  i=$((i+1))  
  #echo $image
done

echo

# this can only be instantiated with # of images
image_dir_array=($(seq 1 $i))


echo "version: \"3\"" >> $a_yml
echo "services:" >> $a_yml

### Filetree
i=0
for image in $image_array; do
  image_dir_array[$i]="$(echo $image | sed 's/\///')"
  #echo "DEBUG: ${image_dir_array[$i]}"
  #touch ./${image_dir_array[$i]}/docker-compose.yml
  this_Dockerfile=/home/redmage/docker-projects/$image/Dockerfile-$image
  case "$image" in
    nginx)
      echo "  $image:" >> $a_yml
      echo "    image: $image" >> $a_yml
      echo "    ports:" >> $a_yml 
      echo "      - 80:80" >> $a_yml
      ;;
    mysql)
      echo "  $image:" >> $a_yml
      echo "    image: $image" >> $a_yml
      echo "    container_name: $image" >> $a_yml
      echo "    ports:" >> $a_yml
      echo "      - 3307:3306" >> $a_yml
      #echo "    volumes_from:" >> $a_yml
      #echo "      - mysql-data" >> $a_yml
      echo "    environment:" >> $a_yml
      echo "      MYSQL_ROOT_PASSWORD: \"nice_password\"" >> $a_yml
      echo "      MYSQL_DATABASE: \"hey_steve\"" >> $a_yml
      echo "      MYSQL_USER: \"user\"" >> $a_yml
      echo "      MYSQL_PASSWORD: \"nice_password\"" >> $a_yml
      echo "echo FROM $image" >> $this_Dockerfile
      ;;
    #*maria*)
    #  i
    #  ;;
    *redmine*)
      echo "  $image:" >> $a_yml
      echo "    image: $image" >> $a_yml
      echo "echo FROM $image" >> $this_Dockerfile
      ;;
    *http*)
      echo "  $image:" >> $a_yml
      echo "    image: $image" >> $a_yml
      echo "echo FROM $image" >> $this_Dockerfile
      ;;
    *mediawiki*)
      echo "  $image:" >> $a_yml
      echo "    image: $image" >> $a_yml
      echo "echo FROM $image" >> $this_Dockerfile
      ;;
    #certbot/dns-digitalocean
    cert*ocean)
      echo "  certbot-dns-digitalocean:" >> $a_yml
      echo "    image: certbot/dns-digitalocean" >> $a_yml
      echo "echo FROM certbot/dns-digitalocean" >> $this_Dockerfile
      ;;
    cert*bot)
      echo "  certbot-certbot:" >> $a_yml
      echo "    image: certbot/certbot" >> $a_yml
      echo "echo FROM certbot/certbot" >> $this_Dockerfile
      ;;
    # webdevops/php-nginx
    web*inx)
      echo "  webdevops-php-nginx:" >> $a_yml
      echo "    image: webdevops/php-nginx" >> $a_yml
      echo "echo FROM webdevops/php-nginx" >> $this_Dockerfile
      ;;
    *)
#      echo "  $image:" >> $a_yml
#      echo "    image: $image" >> $a_yml
#      echo "    dockerfile: $this_Dockerfile" >> $a_yml
#      echo "echo FROM $image" >> $this_Dockerfile
      :
      ;;

      
  esac
  i=$((i+1))  
  #echo ${image_dir_array[$i]}
done

### Run
#for i in mysql; do
#  sudo docker run $i -f ./$i/Dockerfile
#done


#echo ${image_array[*]}
#echo
#echo ${image_dir_array[*]}
