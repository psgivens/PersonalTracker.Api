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
    [Migration("20190407180648_actionitems_date_nullable")]
    partial class actionitems_date_nullable
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.SerialColumn)
                .HasAnnotation("ProductVersion", "2.2.3-servicing-35854")
                .HasAnnotation("Relational:MaxIdentifierLength", 63);

            modelBuilder.Entity("Pomodoro.Api.Models.ActionItemModel", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<DateTime?>("CompletionDate");

                    b.Property<string>("Description");

                    b.Property<DateTime?>("DueDate");

                    b.Property<DateTime>("Modified");

                    b.Property<int>("State");

                    b.Property<string>("Tags");

                    b.Property<string>("UserId");

                    b.HasKey("Id");

                    b.ToTable("ActionItems");
                });

            modelBuilder.Entity("Pomodoro.Api.Models.GroupEntity", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("Name");

                    b.HasKey("Id");

                    b.ToTable("Groups");
                });

            modelBuilder.Entity("Pomodoro.Api.Models.PersonEntity", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<string>("FirstName");

                    b.Property<string>("LastName");

                    b.HasKey("Id");

                    b.ToTable("People");
                });

            modelBuilder.Entity("Pomodoro.Api.Models.PersonGroupRelation", b =>
                {
                    b.Property<long>("Id")
                        .ValueGeneratedOnAdd();

                    b.Property<long>("GroupId");

                    b.Property<long>("MemberId");

                    b.HasKey("Id");

                    b.HasIndex("GroupId");

                    b.HasIndex("MemberId");

                    b.ToTable("PersonGroupRelation");
                });

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

            modelBuilder.Entity("Pomodoro.Api.Models.PersonGroupRelation", b =>
                {
                    b.HasOne("Pomodoro.Api.Models.GroupEntity", "Group")
                        .WithMany("MemberRelations")
                        .HasForeignKey("GroupId")
                        .OnDelete(DeleteBehavior.Cascade);

                    b.HasOne("Pomodoro.Api.Models.PersonEntity", "Member")
                        .WithMany("GroupRelations")
                        .HasForeignKey("MemberId")
                        .OnDelete(DeleteBehavior.Cascade);
                });
#pragma warning restore 612, 618
        }
    }
}
