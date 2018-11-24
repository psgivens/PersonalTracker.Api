FROM gesellix/mountebank

RUN mkdir -p /mocks/conf/

COPY ./startup.sh /mocks/
COPY ./conf/ /mocks/conf/

RUN chmod u+x /mocks/startup.sh

WORKDIR /mocks/

ENTRYPOINT [ "/mocks/startup.sh" ]
CMD [ "--configfile", "/mocks/conf/imposters.ejs"]
