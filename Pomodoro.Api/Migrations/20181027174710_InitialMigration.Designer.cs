﻿// <auto-generated />
using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;
using Pomodoro.Api.Models;

namespace Pomodoro.Api.Migrations
{
    [DbContext(typeof(PomodoroDbContext))]
    [Migration("20181027174710_InitialMigration")]
    partial class InitialMigration
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.SerialColumn)
                .HasAnnotation("ProductVersion", "2.1.4-rtm-31024")
                .HasAnnotation("Relational:MaxIdentifierLength", 63);

            modelBuilder.Entity("Pomodoro.Api.Models.PomodoroEntryModel", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Actual");

                    b.Property<int>("Elapsed");

                    b.Property<DateTime>("Modified");

                    b.Property<string>("Planned");

                    b.Property<DateTime>("StartTime");

                    b.Property<int>("State");

                    b.Property<string>("Tags");

                    b.Property<string>("UserId");

                    b.HasKey("Id");

                    b.ToTable("PomodoroEntries");
                });
#pragma warning restore 612, 618
        }
    }
}
