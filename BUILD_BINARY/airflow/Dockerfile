FROM sanmuk21/sdh-spark-kubernetes:1.0.2.4

ARG DEBIAN_FRONTEND=noninteractive
ARG SLUGIFY_USES_TEXT_UNIDECODE=yes

RUN apt-get update --fix-missing ; exit 0
RUN apt-get -qq install netcat
RUN apt-get -qq install build-essential autoconf libtool pkg-config python-opengl python-imaging python-pyrex python-pyside.qtopengl idle-python2.7 qt4-dev-tools qt4-designer libqtgui4 libqtcore4 libqt4-xml libqt4-test libqt4-script libqt4-network libqt4-dbus python-qt4 python-qt4-gl libgle3 python-dev
RUN apt-get -qq install python-pip
RUN pip install --upgrade pip
RUN pip install setuptools -U
RUN pip install "apache-airflow[]==1.10.2"
RUN pip install --ignore-installed six


ENV PATH="/sdh/spark2/sbin:/sdh/spark2/bin:${PATH}"
COPY start.sh /start.sh
RUN chmod 755 /start.sh

EXPOSE 8080

ENTRYPOINT ["/start.sh"]
