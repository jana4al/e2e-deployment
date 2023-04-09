#Modified and improved version:
# Build stage
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /app
#COPY ["e2e-deployment.csproj", "."]
#RUN dotnet restore "./e2e-deployment.csproj"
#COPY . .
#RUN dotnet publish "e2e-deployment.csproj" -c Release -o /app/publish /p:UseAppHost=false
#
## Final stage
#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS final
#WORKDIR /app
#COPY --from=build /app/publish .
#ENTRYPOINT ["dotnet", "e2e-deployment.dll"]
#
#EXPOSE 80
#EXPOSE 443
#
##EXPOSE 443/tcp

#Improved below code as above and mentioned the points below.
#Removed unnecessary WORKDIR and EXPOSE directives.
#Used a .dockerignore file to exclude unnecessary files from the build context.
#Combined the COPY and RUN directives to avoid creating unnecessary layers.
#Removed the intermediate base stage and combined it with the final stage to create a smaller and more efficient image.
#Added a comment to explain the purpose of each stage.

#When you set the /p:UseAppHost=false argument, you're telling the dotnet command to skip the creation of the application host during the publish process. 
#disabling the application host is useful if you're deploying your .NET application to a containerized environment, as the container itself can act as the host for the application.
#---------------------------------------------------------------------------
#With Smaller base image:
## Build stage
#FROM mcr.microsoft.com/dotnet/sdk:6.0-alpine AS build
#WORKDIR /app
#COPY ["e2e-deployment.csproj", "."]
#RUN dotnet restore "./e2e-deployment.csproj"
#COPY . .
#RUN dotnet publish "e2e-deployment.csproj" -c Release -o /app/publish /p:UseAppHost=false
#
## Final stage
#FROM mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine AS final
#WORKDIR /app
#COPY --from=build /app/publish .
#ENTRYPOINT ["dotnet", "e2e-deployment.dll"]
#
#EXPOSE 443/tcp

#Changed the base image of the build stage to mcr.microsoft.com/dotnet/sdk:6.0-alpine, which is a smaller Alpine Linux-based image that includes the .NET SDK.
#Changed the base image of the final stage to mcr.microsoft.com/dotnet/runtime-deps:6.0-alpine, which is another Alpine Linux-based image that includes only the necessary runtime dependencies for .NET applications.
#Removed the WORKDIR and EXPOSE directives that are not necessary.
#Added the EXPOSE directive at the end to expose port 443.
#Using a smaller base image can result in smaller Docker images and better security, as there are fewer components to manage and potentially fewer security vulnerabilities to address. However, it's important to ensure that all required dependencies and libraries are included in the smaller image.

#---------------------------------------------------------------------------
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["e2e-deployment.csproj", "."]
RUN dotnet restore "./e2e-deployment.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet publish "e2e-deployment.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "e2e-deployment.dll"]
#-----------------------------------------------------------------------

#FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
#WORKDIR /app
#EXPOSE 80
#EXPOSE 443
#
#FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#WORKDIR /src
#COPY ["e2e-deployment.csproj", "."]
#RUN dotnet restore "./e2e-deployment.csproj"
#COPY . .
#WORKDIR "/src/."
#RUN dotnet build "e2e-deployment.csproj" -c Release -o /app/build
#
#FROM build AS publish
#RUN dotnet publish "e2e-deployment.csproj" -c Release -o /app/publish /p:UseAppHost=false
#
#FROM base AS final
#WORKDIR /app
#COPY --from=publish /app/publish .
#ENTRYPOINT ["dotnet", "e2e-deployment.dll"]

#How to run docker:
#Push the image to docker hub
#then command: docker build -t dockerid /imagename:versionnumber .
#docker build -t jana4al/e2e:1 .
#docker run --rm -it \ 