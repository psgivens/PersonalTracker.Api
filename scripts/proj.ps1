




$project = "IdentityManagement"

mkdir src
cd src

# Create the projects
dotnet new classlib -lang 'C#' -o "$project.Data"
dotnet new webapi -lang 'F#' -o "$project.Api"
dotnet new webapi -lang 'F#' -o "$project.Tests"

#Create the solution and add the projects
dotnet new sln -n $project

dotnet sln add "$project.Api"
dotnet sln add "$project.Tests"

# Add the references to each other
dotnet add "$project.Tests" reference "$project.Data"
dotnet add "$project.Tests" reference "$project.Api"
dotnet add "$project.Api" reference "$project.Data"

# Add the ef references to the data project
dotnet add "$project.Data" package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add "$project.Api" package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add "$project.Tests" package Npgsql.EntityFrameworkCore.PostgreSQL

dotnet add "$project.Api" package IdentityServer4
dotnet add "$project.Api" package IdentityServer4.AccessTokenValidation

dotnet build






dotnet build












