# Generated by Django 2.2.7 on 2022-07-19 23:07

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hdr', '0022_auto_20220719_2110'),
    ]

    operations = [
        migrations.AddField(
            model_name='hojaderutacobro',
            name='cobro_actualizar',
            field=models.BooleanField(default=True),
        ),
    ]
