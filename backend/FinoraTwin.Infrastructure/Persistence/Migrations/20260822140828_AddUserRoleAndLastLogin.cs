using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FinoraTwin.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddUserRoleAndLastLogin : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "last_login_at",
                table: "users",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "role",
                table: "users",
                type: "integer",
                nullable: false,
                defaultValueSql: "0");

            migrationBuilder.CreateIndex(
                name: "IX_users_role",
                table: "users",
                column: "role");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_users_role",
                table: "users");

            migrationBuilder.DropColumn(
                name: "last_login_at",
                table: "users");

            migrationBuilder.DropColumn(
                name: "role",
                table: "users");
        }
    }
}
