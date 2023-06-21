# llama_cpp_java
Как я знакомился с alpaca, llama.cpp, coboltcpp, cuda в docker и остальные премудрости ggml.

Вступление:

Я начал изучение решений через ThensorFlow, далее StabbleDiffusion, а вот дальше уже chatGPT (для погружения можете но не обязательно использовать такой путь)
Для входа в тему и ознакомления с alpaca, рекомендую:

https://habr.com/ru/news/723638/            --- отличная статья вкупе с роликом
https://habr.com/ru/articles/724172/        --- но все же мне зашло только после ролика на youtobe

Далее пока вы еще не кинулись себе инсталлировать всякие там Pythorch и Thensor с Cuda а так-же pip, и не потонули в том что оказывается разные релизы разных библиотек нейронного обучения 
зависят, и или совместимы с различными комбинациями версий этих либ и их компонентов, сразу прошу, придержите коней, остудите пыл и почитайте про .env в python, это позволит вам не возвращаться по десять раз
к переустановки локальной, предыдущих установленных сетей. Так-же как мне стало ясно дальше в целом безопасность пк начнет то там то тут испускать пар во все стороны, потому что вовлекшись вы рескуете как и я 
начать тащить себе готовые библиотеки и решения чтобы их скорее пощупать, собственно я опишу то к чему я пришел в самом конце файла, вас же прошу обратиться туда по возможности сейчас(строка 42).

Далее. Значит как и у всех, первым знакомством стал поиск java решений для работы с openApi и chatGPT3, 
что не проблема(ниже один из и тому подобных примеров):

https://gist.github.com/gantoin/190684c344bb70e5c5f9f2339c7be6ed

в итоге только за невозможностью оплатить доступ к официальным инструментам и последующей:

https://www.google.com/amp/s/habr.com/ru/amp/post/712534/
https://www.youtube.com/watch?v=ivXcInXR5jo --- уже дальше дообучение

конечно же визуализации своей личности в модели, далее с такими вопросами возникает необходимость разобраться в том что же такое эта ggml и чем отличается от других форматов моделей,
процесс обучения такой на наборе данных в json, сам еще в процессе погружения но выше привел пару ссылок.

Я больше работаю на java и c#(но и к с++ и python норм отношусь, но то в какую лепешку наступаешь при вхождении в it первой прилепает както по особенному)) ) 
так что стали интересны решения в интернете для реализации своей системы запоминания) именно на этих или около с минималкой языках,
нашел некоторые примеры, но там доступ ведется в консоль, такое решил не копировать, сам своих велосипедов накурочить могу.

повлекло интерес к автономным решениям данной необходимости, тут конечно же всплыли alpaca, llama и coboldcpp

https://github.com/LostRuins/koboldcpp        --- coboldcpp

https://github.com/Nuked88/alpaca.http        --- alpaca rest на python, тут инетересно

https://github.com/ggerganov/llama.cpp        --- llama.cpp

------------------------------------------------------------------- Среды и окружение ---------------------------------------------------------------
я долго шел к этому и оно назрело, в той же llama.cpp я не сразу заметил пункты про docker да и не мудрено, почитав про llama.cpp я увидел упоминания переноса вычислений на GPU от чего
сразу решил что вероятно это тогда точно сугубо локальное решение, и ни о какой alpaca конфетке с RaspberyPI речи не может идти. Каким же было мое удивление, когда я наткнулся на это:

https://learn.microsoft.com/ru-ru/windows/ai/directml/gpu-cuda-in-wsl
https://github.com/NVIDIA/nvidia-docker

и тут все стало ясно, docker - наше все, никакие .env не нужны, image можно хранить и делать с ним все аля cd/cd-R диск из прошлого
далее было вникание как развернуть то или иное решение в docker, что изэтого вышло опишу в следующих коммитах.

https://github.com/fbaldassarri/llama-cpp-container/tree/main
https://github.com/ashleykleynhans/audiocraft-docker

https://github.com/LostRuins/koboldcpp/discussions/251 -->
Я создал несколько образов docker для KoboldCPP, один только для CPU, а другой и для CPU, и для GPU (изображение только для CPU значительно меньше для тех, кто не использует GPU)
Обновлено до версии 1.31.2
https://hub.docker.com/r/noneabove1182/koboldcpp-gpu
https://hub.docker.com/r/noneabove1182/koboldcpp

Генерация аватара за бесплатно:
https://www.youtube.com/watch?v=V2efVSXSlqc

Vicuna сборки
