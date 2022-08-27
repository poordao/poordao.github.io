---
title: 个人网站加入remark42评论功能流程记录
cover: /images/comment-or-not.png
photos:
- /images/comment-or-not.png
comment: true
tags:
  - 前端
categories: 开发
keywords: remark42,评论系统,hexo博客,个人网站
abbrlink: 35065
---

这几天准备搭建一个个人博客，用来记录一些事情，还有生活中的点滴，搭建完成了发现没有评论功能也不行，偶尔也会有人想发表一下自己的看法，却没有地方输出，这是比较遗憾的，于是就调研了下市场上的评论系统，发现remark42非常适合，轻巧、外观还算可以，主要是开源不收集数据，不用数据库，实际上用的是文件数据库，至少不用安装其他的，所以就拿来用了。

<!--more-->

官方有文档，算比较详细，但是如果对于新手来说还有许多弯路要走，市面上的教程写的都很笼统，感觉像一个抄一个的，没有一个是能够解决问题的，要么就是有些人测试了一下然后就弄了一篇教程就发布了，完全不符合需要实际使用的场景，也有可能有些人轻车熟路，觉得有些东西是最基本的，根本不用写出来，实际上有些最基本的东西，如果不记录一下，过一段时间早都忘得一干二净，就像服务器我一般很少打开，除非遇到什么问题或者需要升级的时候才会打开，所以最基本的东西早都忘光了。

# 准备工作

1. 已搭建好的博客
2. 服务器
3. nginx
4. 域名
5. Remark42

# 后端部署

下载官方的文件，注意下版本，如果运行不起来，可能是版本选错了，运行有两种方式，docker和直接运行，我是选择直接运行，这样简单快捷。所以教程也是没有使用docker

下载后直接解压，文件结构非常简单

	+-- remark42.linux-amd64
	+-- README.md
	+-- LICENSE

将remark42.linux-amd64文件上传至你的服务器的任何目录下，最好是自己熟悉的目录下，方便维护，上传上去之后其实就可以直接运行了，但是注意下，remark42占用的是8080端口，我的服务器里有跑java项目，所以又将java项目改了端口，实际上我是不知道如何更改remark42的端口，哈哈，另外要是国内的服务器可能需要自己开放端口权限操作，否则启动不了。

## 测试运行

Linux如何运行二进制文件我也忘记了，搞了好几次才可以，注意下就可以了，对了运行之前nginx必须要运行起来，不配置也可以运行起来测试是没问题的。

测试运行命令：

	./remark42.linux-amd64 server --secret=12345 --url=http://127.0.0.1:8080
	
注意：这一长串都是一起的，最主要的是命令前的 “./” ，如果不加这个，是无法运行的，这个对于老司机来说不是什么问题，对于新手来说，就这个完全可以挡住你。

运行之后你浏览器打开 http://127.0.0.1:8080/web, （把127.0.0.1换成你服务器的公网ip地址）能够看到一个如下的页面，说明你已经成功一半了

![运行成功](/images/image-20220515185339060.png)

比较重要的几个参数说明：

* --url Remark42 服务器的 URL 必须的参数，测试的时候设置的是http://127.0.0.1:8080 地址，但是上线后填的地址就是网站里填的地址，网站或者博客就是通过这个地址来获取你部署在服务器上的所有资源的
* --site 这个参数默认是 remark, 必须和前端的配置一致，相当于一个网站的唯一标识
* --secret 必须参数，用来签署token用的
* --auth.anon 是否允许匿名评论 (匿名评论也需要随便填入一个昵称)，只有 key 没有值。

其他配置说明请参考官方说明 Remark42 服务器配置说明，非常详细，其他参数按照上面的格式跟着后面就可以了，不分顺序，有的参数不需要值，具体的哪些不需要试一下就知道了。

如果评论有邮箱登录验证的需求可以开通邮箱验证的功能，继续给启动命令后面加参数就可以了，如果只有匿名评论那么参数就会少许多

# nginx配置

配置之前需要购买域名，国外有NameSilo，等等，国内的有阿里，等等。

remark42的官网配置有些可能有些过时了，所以会有一些小问题，这里展示一下具体的配置，nginx不懂的可以搜一下教程看看。

	server {
	    listen 443 ssl;
	    server_name remark42.example.com;
	   
	    ssl_certificate /etc/nginx/ssl/remark42.example.com.pem;
	    ssl_certificate_key /etc/nginx/ssl/remark42.example.com.key;
	    gzip on;
	    gzip_types text/plain application/json text/css application/javascript application/x-javascript text/javascript text/xml application/xml application/rss+xml application/atom+xml application/rdf+xml;
	    gzip_min_length 1000;
	    gzip_proxied any;
	    
	    location ~ /\.git {
	        deny all;
	    }
	
	    location /index.html {
	         proxy_redirect off;
	         proxy_set_header X-Real-IP $remote_addr;
	         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
	         proxy_set_header Host $http_host;
	         proxy_pass  http://127.0.0.1:8080/web/index.html;
	     }
	
	    location / {
	         proxy_redirect   off;
	         proxy_set_header X-Real-IP $remote_addr;
	         proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
	         proxy_set_header  Host $http_host;
	         proxy_pass   http://127.0.0.1:8080/;
	    }
	
	    access_log   /var/log/nginx/remark42.log;
	}
	
	server {
	  listen 80;
	  server_name remark42.example.com;
	  return  301 https://remark42.example.com$request_uri;
	}

可以把remark42.example.com换成你自己的地址，记得域名需要添加dns解析记录。

需要注意的就是remark42启动时填写的url必须要使用https，也就是需要ssl证书，否则有些浏览器无法访问或者不同的手机也会出现不同的情况，所以ssl要搞，国际的cloudflare有免费的，国内阿里云有免费的，免费的实际上已经非常够用了。

如果域名和ssl的提供商不是同一个平台也是可以的，后面还需要带有域名的邮箱，这是一套的东西，所以都得有，邮箱用来通知用户和网站评论的验证之类，我试过个人邮箱，大都是无法使用smtp发送邮件，要么就是不支持，要么就是发不出去邮件，国内的邮箱没有测试，国内的邮箱已经不使用了，所以直接忽略了，免费的邮箱服务商后面推荐。

# 前端部署

前端没有什么好说的，基本上就是通过配置remark42的参数，最后全部通过js加载页面和数据的，按照官网的配置复制进去，放在你想要放的地方就可以了，我用的是主题，主题的作者已经加入了remark42的功能，因此没有过多的研究，简单的看了一下，还是用的官方文档里写的东西，没有什么特别的。

Hexo主题里js代码

	<section id="remark42"></section>
	<script>
	    (function() {
	        window.remark_config = {
	            host: "<%= config.aomori_remark42.host || '' %>",
	            site_id: "<%= config.aomori_remark42.site_id || '' %>",
	            max_shown_comments: "<%= config.aomori_remark42.max_shown_comments || 15 %>",
	            theme: "<%= config.aomori_remark42.theme || 'dark' %>",
	            locale: "<%= config.aomori_remark42.locale || 'en' %>",
	            show_email_subscription: "<%= config.aomori_remark42.show_email_subscription || false %>",
	            components: ['embed']
	        }
	        var d = document, s = d.createElement('script');
	        s.src = remark_config.host + '/web/embed.js';
	        s.defer = true;
	        (d.head || d.body).appendChild(s);
	    })();
	</script>

_config.yml 文件配置
	
	aomori_remark42:
	  enable: true
	  # remark42里的url和host保持一致
	  host: 'https://remark42.example.com'
	  # remark42的site，网站唯一标识
	  site_id: 'remark'
	  # 最多显示评论数量
	  max_shown_comments: 10
	  theme: "light"
	  locale: "zh"
	  # 是否显示邮件订阅
	  show_email_subscription: true
	  
# 其他小细节

如果能走完上面的流程，基本上你的网站就能使用remark42了，虽然流程不是非常的详细，但是要紧的点都提到了，注意下就可以了，至于其他的问题，比如域名、ssl的问题就需要自己解决了，这篇文章不是记录这些问题的，涉及的东西确实有点多，所以没法全部写出来，要不然就成了四不像。

remark42的登录我觉得可以开通邮箱和匿名登录，其他的第三方我觉得对于用户来讲有点麻烦，并且现在很多人都不愿意将自己的社交账号交给第三方，这个涉及到自己的隐私，所以还是不做为好，邮箱倒也还好，只要不要使用国内的邮箱一般隐私性还是比较好的，众所周知国内的任何东西都是实名制的，所以这大家会觉得怪怪的；另外匿名评论功能也非常的好，有些人确实只是想随意发泄一下，最后发现登录流程太麻烦，说一句话的成本太大，也就放弃了。

所以匿名评论可以解决这些问题，如果评论的人说的话自己实在看不下去，那么管理员可以选择删除它，或者屏蔽掉，remark42是没有管理员页面的，可以使用自己的账号登录，匿名也可以，登录后会生成一个id，把这个id作为参数，也就是管理员的参数，追加至启动命令后面，启动remark42，然后打开评论页面之后，就会有相应的管理员的操作功能出现。

## smpt域名邮箱
通知是一个非常重要的功能，使用的场景太多了，所以几乎是100%要做的。

比如有人评论了你的文章，需要通知，否则你不能天天守着他看，有人回复了你，需要通知，登录需要验证，等等，因此邮箱的通知是非常好的选择。

免费的、支持smtp、匿名的个人邮箱，市面上基本上没有，因此只有把自己的域名作为邮箱是非常好的一个选择，但是这种基本上必须得是一个组织或者公司才可以，大多数都是收费的，当然这种都是支持smtp的，免费的找了一大圈几乎没有，而且邮箱对于发送这需要发送的内容又比较严格，所以能用的很少，最后找到了Mailjet，是法国的电子邮件营销平台，可以支持smtp和api的邮件发送，可以让你的域名变成域名邮箱，具体实现方式可以自行去研究，或者直接去官网体验。

## Linux后台运行文件

上面说的运行命令只能是前台运行程序，关闭运行窗口后程序也就通知运行了，后台运行命令：

	nohup ./remark42.linux-amd64 server --secret=remark --url=https://remark42.example.com --site=remark --auth.anon --admin.shared.email=remark@gmail.com --notify.admins=email --notify.users=email --smtp.tls --notify.email.from_address=noreply@ example.com --notify.email.verification_subj=verification --smtp.host=in-v3.mailjet.com --smtp.port=465 --smtp.timeout=20s --smtp.username=xxxxxxx --smtp.password=xxxxxxx --auth.email.subj=confirmation --auth.email.from=noreply@ example.com --auth.email.enable --admin.shared.id=email_bfbaeec7004bb91a1101367e9c1969def5dcba5 >remark.log 2>&1 &
	
以上命令包含的功能：管理员email，邮箱通知email，邮箱配置，开启邮箱登录，匿名评论，管理员id

以上就是全部内容

